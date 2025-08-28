// NexiPayments/www/NexiPayments.js
var exec = require("cordova/exec");

var PLUGIN_NAME = "NexiPayments";

var NexiPayments = {
  /**
   * Initializes the Nexi SDK and starts a payment transaction.
   * @param {string} orderId - The order ID for the transaction.
   * @param {string} paymentUrl - The payment URL from your server.
   * @param {Function} successCallback - The callback function for success.
   * @param {Function} errorCallback - The callback function for errors.
   */
  startPayment: function (orderId, paymentUrl, successCallback, errorCallback) {
    exec(successCallback, errorCallback, PLUGIN_NAME, "startPayment", [
      orderId,
      paymentUrl,
    ]);
  },
};

// Export the object to be accessible via cordova.plugins.NexiPayments
module.exports = NexiPayments;
