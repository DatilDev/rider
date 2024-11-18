//Add to assets/js/app.js
const NostrProvider = {
  async getPublicKey() {
    if (typeof window.nostr === "undefined") {
      throw new Error("Nostr extension not found");
    }
    return await window.nostr.getPublicKey();
  },

  async signEvent(event) {
    if (typeof window.nostr === "undefined") {
      throw new Error("Nostr extension not found");
    }
    return await window.nostr.signEvent(event);
  }
};

// Make NostrProvider available to LiveView hooks
window.NostrProvider = NostrProvider;