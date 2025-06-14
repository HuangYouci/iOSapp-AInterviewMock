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
          nextUserId = (counterDoc.data()?.nextUserId as number) + 1;
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

        transaction.set(counterRef, {nextUserId: nextUserId},
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
