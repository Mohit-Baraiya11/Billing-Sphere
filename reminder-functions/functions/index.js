const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.database();

exports.checkReminders = functions.pubsub
  .schedule("every 1 minutes")
  .timeZone("Asia/Kolkata") // Set to IST (Indian Standard Time)
  .onRun(async (context) => {
    const now = new Date();
    const currentTime = now.toISOString().slice(0, 16); // "YYYY-MM-DDTHH:MM"

    const usersSnap = await db.ref("users").once("value");
    const users = usersSnap.val();

    for (const userId in users) {
      const userData = users[userId];
      const reminders = userData.Reminder || {};
      const token = userData.fcmToken;
      if (!token) continue;

      for (const reminderId in reminders) {
        const reminder = reminders[reminderId];
        const reminderTime = reminder.reminderTime?.slice(0, 16); // Match format

        if (reminderTime === currentTime && !reminder.sent) {
          const payload = {
            notification: {
              title: "⏰ Reminder Time!",
              body: reminder.text || "It's time for your reminder!",
            },
          };

          await admin.messaging().sendToDevice(token, payload);
          await db.ref(`users/${userId}/Reminder/${reminderId}/sent`).set(true);
        }
      }
    }

    return null;
  });
