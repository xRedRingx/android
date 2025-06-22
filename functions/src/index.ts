import * as admin from "firebase-admin";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";

// If you haven't initialized, do so: admin.initializeApp();

// [ ... your existing Cloud Functions ... ]

/**
 * Cloud Function that triggers when a booking is updated.
 * Specifically checks if the status changed to 'canceled'.
 */
export const sendCancellationNotification = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    // Check if the status has changed to 'canceled'
    if (beforeData?.status !== "canceled" && afterData?.status === "canceled") {
      const barberId = afterData.barberId;
      const customerName = afterData.customerName;
      console.log(`Booking ${event.params?.bookingId}
          was canceled by ${customerName}. Notifying barber ${barberId}.`);

      // Get the barber's user document to find their FCM token
      const barberRef = admin.firestore().collection("users").doc(barberId);
      const barberDoc = await barberRef.get();

      if (!barberDoc.exists) {
        console.log(`Barber document for ID ${barberId} does not exist.`);
        return;
      }

      const barberData = barberDoc.data();
      if (!barberData || !barberData.fcmToken) {
        console.log(`Barber ${barberId} does not have an FCM token.`);
        return;
      }

      const fcmToken = barberData.fcmToken;

      const payload = {
        notification: {
          title: "Appointment Canceled",
          body: `${customerName} has canceled their appointment.`,
          sound: "default",
        },
      };

      try {
        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log(`Cancellation notification sent to barber ${barberId}.`);
      } catch (error) {
        console.error("Error sending cancellation notification:", error);
      }
    }
  }
);
