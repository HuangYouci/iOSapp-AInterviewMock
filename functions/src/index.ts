import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// == 介面 ==
interface CreateUserProfileData {
    userEmail?: string;
    userName?: string;
}

interface UpdateUserCoinsData {
    amount: number;
}

// 1. Cloud Function: 創建初始用戶 Profile
export const createInitialUserProfile = onCall(
  {region: "asia-east1"},
  async (request) => {
    // 1. 驗證請求是否已登入
    if (!request.auth) {
      throw new HttpsError("unauthenticated",
        "The function must be called while authenticated.");
    }

    const uid = request.auth.uid;
    const data = request.data as CreateUserProfileData;
    const userEmail = data.userEmail;
    const userName = data.userName;

    const userProfileRef = db.collection("users").doc(uid);
    const counterRef = db.collection("system").doc("userCounter");

    let newProfileData: any;

    try {
      await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userProfileRef);
        if (userDoc.exists) {
          throw new HttpsError("already-exists",
            "User profile already exists for this UID.");
        }

        const counterDoc = await transaction.get(counterRef);
        let nextUserId = 1;
        if (counterDoc.exists && typeof counterDoc
          .data()?.nextUserId === "number") {
          nextUserId = counterDoc.data()?.nextUserId as number;
        }

        newProfileData = {
          userId: nextUserId,
          userEmail: userEmail || null,
          userName: userName || null,
          coins: 0,
          creationDate: new Date(),
          updateDate: new Date(),
          lastloginDate: new Date(),
        };

        transaction.set(counterRef, {nextUserId: nextUserId + 1},
          {merge: true});
        transaction.set(userProfileRef, newProfileData);
      });

      logger.info(`User profile created for 
        UID: ${uid} with App UserID: ${newProfileData.userId}`);
      return {
        success: true,
        message: "User profile created successfully.",
        userProfile: newProfileData,
      };
    } catch (error: any) {
      logger.error(`Failed to create user
         profile for UID: ${uid}. Error:`, error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal",
        "Failed to create user profile due to an internal error.",
        error.message);
    }
  }
);

// 2. Cloud Function: 更新用戶金幣
export const updateUserCoins = onCall(
  {region: "asia-east1"},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated",
        "The function must be called while authenticated.");
    }

    const uid = request.auth.uid;
    const data = request.data as UpdateUserCoinsData;
    const amount = data.amount;

    if (!Number.isInteger(amount) || amount === 0) {
      throw new HttpsError("invalid-argument",
        "Amount must be a non-zero integer.");
    }

    const userProfileRef = db.collection("users").doc(uid);

    try {
      let finalCoins = 0;
      await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userProfileRef);

        if (!userDoc.exists) {
          throw new HttpsError("not-found",
            "User profile not found.");
        }

        const currentCoins = userDoc.data()?.coins || 0;
        const newCoins = currentCoins + amount;

        transaction.update(userProfileRef, {
          coins: newCoins,
          updateDate: new Date(),
        });
        finalCoins = newCoins;
      });

      logger.info(`User ${uid} coins updated
        by ${amount}. New total: ${finalCoins}`);
      return {success: true, newCoins: finalCoins};
    } catch (error: any) {
      logger.error(`Failed to update coins
        for UID: ${uid}. Error:`, error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal",
        "Failed to update coins.", error.message);
    }
  });

// 3. Cloud Function: 更新用戶最後登入時間
export const updateUserLastLoginDate = onCall(
  {region: "asia-east1"}, // <-- V2 設定地區的方式
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated",
        "The function must be calledwhile authenticated.");
    }

    const uid = request.auth.uid;
    const userProfileRef = db.collection("users").doc(uid);

    try {
      await userProfileRef.update({
        lastloginDate: new Date(),
        updateDate: new Date(),
      });

      logger.info(`User ${uid} last login date updated.`);
      return {success: true,
        message: "Last login date updated successfully."};
    } catch (error: any) {
      logger.error(`Failed to update
        last login date for UID: ${uid}. Error:`, error);
      throw new HttpsError("internal",
        "Failed to update last login date.", error.message);
    }
  });

// 4. Cloud Function: 刪除帳號
export const deleteUserAccount = onCall(
  {region: "asia-east1"},
  async (request) => {
    // 步驟 1: 驗證使用者是否已登入。
    if (!request.auth) {
      // 如果未登入就嘗試呼叫，則拋出錯誤。
      throw new HttpsError("unauthenticated",
        "You must be logged in to delete your account.");
    }

    const uid = request.auth.uid;
    logger.info(`Account deletion process started for UID: ${uid}.`);

    const userProfileRef = db.collection("users").doc(uid);

    try {
      // 步驟 2: 刪除 Firebase Authentication 中的使用者紀錄。
      // 我們先刪除 Auth 紀錄，因為這是用戶的「身份」。
      // 如果這步失敗，後續操作就不應進行。
      // 如果這步成功，用戶就再也無法登入了。
      await admin.auth().deleteUser(uid);
      logger.info(`Successfully deleted Firebase Auth user for UID: ${uid}.`);

      // 步驟 3: 刪除 Firestore 中的使用者 Profile 文件。
      // 即使這一步失敗，用戶也已經無法登入，資料變成了「孤兒資料」，
      // 這比資料被刪除但用戶還能登入的狀況要安全。
      await userProfileRef.delete();
      logger.info(`Successfully deleted Firestore profile for UID: ${uid}.`);

      // 步驟 4: 返回成功訊息給客戶端。
      return {
        success: true,
        message: "Your account and all associated data have been deleted.",
      };
    } catch (error: any) {
      // 步驟 5: 處理錯誤。
      logger.error(`Failed to delete account for UID: ${uid}. Error:`, error);
      // 如果錯誤是已知的 HttpsError，直接拋出。
      if (error instanceof HttpsError) {
        throw error;
      }
      // 將其他類型的錯誤包裝成 HttpsError 再拋出，方便客戶端處理。
      // 例如，如果 deleteUser 找不到用戶，會拋出 auth/user-not-found 錯誤。
      throw new HttpsError("internal",
        "An error occurred while deleting your account.",
        error.message);
    }
  }
);
