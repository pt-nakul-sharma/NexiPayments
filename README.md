# NexiPayments Cordova Plugin

A Cordova plugin for integrating Nexi payment processing into your mobile applications. This plugin provides a seamless way to handle secure payment transactions using the official Nexi SDK.

## Features

- 🔒 **Secure Payment Processing** - Integrates with official Nexi SDK
- 📱 **iOS Support** - Native iOS implementation using NexiPay SDK v1.4.8
- ⚡ **Simple API** - Easy-to-use JavaScript interface
- 🔄 **Async Callbacks** - Promise-based transaction handling
- ✅ **Transaction Management** - Complete payment lifecycle handling

## Platform Support

| Platform | Support | Version     |
| -------- | ------- | ----------- |
| iOS      | ✅      | iOS 11+     |
| Android  | ❌      | Coming Soon |

## Installation

### Prerequisites

- Cordova CLI 8.0.0+
- iOS 11.0+ (for iOS builds)
- CocoaPods (for iOS dependency management)

### Install Plugin

```bash
cordova plugin add cordova-plugin-nexipayments
```

### iOS Setup

The plugin automatically configures the NexiPay SDK via CocoaPods. After installation:

1. Navigate to your iOS platform folder:

   ```bash
   cd platforms/ios
   ```

2. Install CocoaPods dependencies:

   ```bash
   pod install
   ```

3. Open the `.xcworkspace` file (not `.xcodeproj`) in Xcode for further development.

## Usage

### Basic Payment Flow

```javascript
// Initialize payment
const orderId = "ORDER_12345";
const paymentUrl = "https://your-server.com/payment-url";

cordova.plugins.NexiPayments.startPayment(
  orderId,
  paymentUrl,
  function (result) {
    // Success callback
    console.log("Payment successful:", result);
    handlePaymentSuccess(result);
  },
  function (error) {
    // Error callback
    console.log("Payment failed:", error);
    handlePaymentError(error);
  }
);
```

### Success Response

```javascript
{
    "status": "success",
    "transactionId": "TXN_789012345",
    "correlationId": "CORR_123456789"
}
```

### Error Response

```javascript
{
    "status": "failure",
    "message": "Payment was cancelled by user",
    "correlationId": "CORR_123456789"
}
```

## API Reference

### `startPayment(orderId, paymentUrl, successCallback, errorCallback)`

Initiates a payment transaction using the Nexi payment system.

**Parameters:**

| Parameter         | Type     | Required | Description                           |
| ----------------- | -------- | -------- | ------------------------------------- |
| `orderId`         | string   | ✅       | Unique identifier for the order       |
| `paymentUrl`      | string   | ✅       | Payment URL received from your server |
| `successCallback` | function | ✅       | Called when payment succeeds          |
| `errorCallback`   | function | ✅       | Called when payment fails             |

**Success Callback Data:**

| Field           | Type   | Description                 |
| --------------- | ------ | --------------------------- |
| `status`        | string | Always "success"            |
| `transactionId` | string | Nexi transaction identifier |
| `correlationId` | string | Correlation ID for tracking |

**Error Callback Data:**

| Field           | Type   | Description                                |
| --------------- | ------ | ------------------------------------------ |
| `status`        | string | Always "failure"                           |
| `message`       | string | Human-readable error message               |
| `correlationId` | string | Correlation ID for tracking (if available) |

## Integration Example

### Complete Payment Flow

```javascript
class PaymentService {
  constructor() {
    this.isPaymentInProgress = false;
  }

  async processPayment(orderData) {
    if (this.isPaymentInProgress) {
      throw new Error("Payment already in progress");
    }

    try {
      this.isPaymentInProgress = true;

      // Get payment URL from your backend
      const paymentUrl = await this.getPaymentUrl(orderData);

      // Start Nexi payment
      const result = await this.startNexiPayment(orderData.orderId, paymentUrl);

      // Verify payment with your backend
      await this.verifyPayment(result.transactionId);

      return result;
    } finally {
      this.isPaymentInProgress = false;
    }
  }

  startNexiPayment(orderId, paymentUrl) {
    return new Promise((resolve, reject) => {
      cordova.plugins.NexiPayments.startPayment(
        orderId,
        paymentUrl,
        resolve,
        reject
      );
    });
  }

  async getPaymentUrl(orderData) {
    // Implement your backend API call
    const response = await fetch("/api/create-payment", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(orderData),
    });

    if (!response.ok) {
      throw new Error("Failed to create payment");
    }

    const data = await response.json();
    return data.paymentUrl;
  }

  async verifyPayment(transactionId) {
    // Verify payment completion with your backend
    const response = await fetch(`/api/verify-payment/${transactionId}`);

    if (!response.ok) {
      throw new Error("Payment verification failed");
    }

    return response.json();
  }
}

// Usage
const paymentService = new PaymentService();

document.getElementById("pay-button").addEventListener("click", async () => {
  try {
    const result = await paymentService.processPayment({
      orderId: generateOrderId(),
      amount: 99.99,
      currency: "EUR",
    });

    showSuccessMessage("Payment completed successfully!");
  } catch (error) {
    showErrorMessage(`Payment failed: ${error.message}`);
  }
});
```

## Error Handling

### Common Error Scenarios

| Error Type        | Possible Causes               | Solutions                          |
| ----------------- | ----------------------------- | ---------------------------------- |
| Invalid Arguments | Missing orderId or paymentUrl | Validate parameters before calling |
| Network Error     | Poor connectivity             | Implement retry logic              |
| User Cancellation | User backs out of payment     | Handle gracefully in UI            |
| SDK Error         | Nexi SDK issues               | Check SDK documentation            |

### Best Practices

1. **Validate Input**: Always validate `orderId` and `paymentUrl` before calling the plugin
2. **Handle Cancellations**: Users may cancel payments - handle this gracefully
3. **Implement Timeouts**: Set reasonable timeouts for payment operations
4. **Secure Communication**: Always use HTTPS for payment URLs
5. **Backend Verification**: Verify all payments on your backend server

## Configuration

### iOS Configuration

The plugin automatically configures the following:

- **NexiPay SDK**: Version 1.4.8 from official repository
- **CocoaPods Integration**: Automatic dependency management
- **Plugin Registration**: Registered as `cordova.plugins.NexiPayments`

### Custom Configuration

If you need to use a different NexiPay SDK version, modify `plugin.xml`:

```xml
<pod name="NexiPay" git="https://github.com/NexiPayments/sdk-ios" tag="YOUR_VERSION"/>
```

## Development

### Building the Plugin

1. Clone the repository
2. Make your changes
3. Test on a real device (payment testing requires physical devices)

### Testing

```bash
# Add to test project
cordova create testapp
cd testapp
cordova plugin add /path/to/cordova-plugin-nexipayments
cordova platform add ios
cordova build ios
```

### Debugging

Enable debug logging in your app:

```javascript
// Add debug logging
const originalStartPayment = cordova.plugins.NexiPayments.startPayment;
cordova.plugins.NexiPayments.startPayment = function (
  orderId,
  paymentUrl,
  success,
  error
) {
  console.log("Starting payment:", { orderId, paymentUrl });

  originalStartPayment(
    orderId,
    paymentUrl,
    function (result) {
      console.log("Payment success:", result);
      success(result);
    },
    function (err) {
      console.log("Payment error:", err);
      error(err);
    }
  );
};
```

## Requirements

### iOS Requirements

- **iOS Version**: 11.0+
- **Xcode**: 12.0+
- **CocoaPods**: 1.10.0+
- **Swift**: 5.0+ (NexiPay SDK requirement)

### Cordova Requirements

- **Cordova CLI**: 8.0.0+
- **cordova-ios**: 6.0.0+

## Troubleshooting

### Common Issues

**Q: Build fails with CocoaPods errors**
A: Ensure CocoaPods is updated and run `pod install` in the iOS platform directory.

**Q: Plugin not found error**
A: Verify the plugin is properly installed with `cordova plugin list`.

**Q: Payment URL invalid**
A: Ensure your backend generates valid Nexi payment URLs and uses HTTPS.

**Q: App crashes on payment start**
A: Test on a physical device - payment SDKs often don't work in simulators.

### Debug Steps

1. Check plugin installation: `cordova plugin list`
2. Verify iOS build: `cordova build ios --verbose`
3. Check device logs in Xcode Console
4. Validate payment URL format with your backend team

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Guidelines

- Follow existing code style
- Add JSDoc comments for new methods
- Test on real devices
- Update documentation

## License

This plugin is licensed under the MIT License. See LICENSE file for details.

## Support

- **Issues**: Report bugs via GitHub Issues
- **Documentation**: Check the official Nexi developer documentation
- **Community**: Join the Cordova community forums

## Changelog

### Version 1.0.0

- Initial release
- iOS support with NexiPay SDK 1.4.8
- Basic payment functionality
- Error handling and callbacks

---

**Note**: This plugin is currently iOS-only. Android support is planned for future releases.
