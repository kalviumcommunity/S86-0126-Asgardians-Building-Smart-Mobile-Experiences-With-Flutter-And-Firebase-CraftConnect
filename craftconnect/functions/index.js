const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ðŸ”¥ Trigger when a new task is added
exports.onTaskCreated = functions.firestore
    .document("tasks/{taskId}")
    .onCreate((snapshot, context) => {
      const taskData = snapshot.data();

      console.log("âœ… New task created");
      console.log("Task ID:", context.params.taskId);
      console.log("Task Data:", taskData);

      // Auto-add status if missing
      if (!taskData.status) {
        return snapshot.ref.update({
          status: "Pending",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return null;
    });
