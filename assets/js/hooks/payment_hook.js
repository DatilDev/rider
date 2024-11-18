
//assets/js/hooks/payment_hook.js
const PaymentHook = {
  mounted() {
    this.handleEvents()
  },

  handleEvents() {
    this.handleEvent("show_invoice", ({invoice, amount_sats}) => {
      // Show QR code and amount for the HODL invoice
      const qrcode = new QRCode(document.getElementById("qr-code"), {
        text: invoice,
        width: 256,
        height: 256
      });

      document.getElementById("payment-amount").innerText = 
        `Amount: ${amount_sats} sats`;
    });
  }
};

export default PaymentHook;