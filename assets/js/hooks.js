//Add to assets/js/hooks.js
const Hooks = {
  NostrExtension: {
    mounted() {
      this.handleClick()
    },
    
    handleClick() {
      this.el.addEventListener("click", () => {
        if (typeof window.nostr !== "undefined") {
          this.pushEvent("extension_found", {});
        } else {
          this.pushEvent("extension_not_found", {});
        }
      });
    }
  }
};

// Event handlers for Nostr extension communication
window.addEventListener("phx:checkNostrExtension", (e) => {
  if (typeof window.nostr !== "undefined") {
    window.pushEvent("extension_found", {});
  } else {
    window.pushEvent("extension_not_found", {});
  }
});

window.addEventListener("phx:requestPublicKey", async (e) => {
  try {
    const pubkey = await NostrProvider.getPublicKey();
    window.pushEvent("public_key_received", { pubkey });
  } catch (error) {
    window.pushEvent("extension_error", { error: error.message });
  }
});

window.addEventListener("phx:signEvent", async (e) => {
  try {
    const signedEvent = await NostrProvider.signEvent(e.detail.event);
    window.pushEvent("event_signed", { event: signedEvent });
  } catch (error) {
    window.pushEvent("extension_error", { error: error.message });
  }
});

export default Hooks;