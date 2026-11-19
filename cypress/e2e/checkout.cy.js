// Cart and checkout up to the hand-off to Stripe (Stripe's hosted page is not automated).
describe("Cart and checkout", () => {
  const stamp = Date.now();

  it("fills the cart, edits it, and shows a Manitoba invoice with taxes (happy path)", () => {
    cy.visit("/products");
    cy.contains("Add to cart").first().click();
    cy.contains("was added to your cart").should("be.visible");
    cy.visit("/cart");
    cy.get("input[type=number]").first().clear().type("2");
    cy.contains("Update").click();
    cy.contains("Quantity updated").should("be.visible");

    cy.contains("Proceed to checkout").click();
    cy.url().should("include", "/users/sign_in");
    cy.contains("Create an account").click();
    cy.get("#user_username").type(`buyer_${stamp}`);
    cy.get("#user_email").type(`buyer_${stamp}@example.com`);
    cy.get("#user_password").type("trailmix123");
    cy.get("#user_password_confirmation").type("trailmix123");
    cy.contains("input", "Sign up").click();

    cy.visit("/cart");
    cy.contains("Proceed to checkout").click();
    cy.contains("Please complete your address").should("be.visible");
    cy.get("#user_first_name").type("Pat");
    cy.get("#user_last_name").type("Camper");
    cy.get("#user_address_line1").type("123 Portage Ave");
    cy.get("#user_city").type("Winnipeg");
    cy.get("#user_province_id").select("Manitoba");
    cy.get("#user_postal_code").type("R3C 0A5");
    cy.contains("input", "Save address").click();

    cy.contains("Invoice").should("be.visible");
    cy.contains("GST (5.0%)").should("exist");
    cy.contains("PST (7.0%)").should("exist");
    cy.contains("Grand total").should("exist");
  });

  it("removes an item independently of quantity editing and shows an empty cart", () => {
    cy.visit("/products");
    cy.contains("Add to cart").first().click();
    cy.visit("/cart");
    cy.contains("Remove").click();
    cy.contains("Your cart is empty").should("be.visible");
  });

  it("rejects an invalid address (unhappy path)", () => {
    cy.visit("/users/sign_up");
    cy.get("#user_username").type(`badaddr_${stamp}`);
    cy.get("#user_email").type(`badaddr_${stamp}@example.com`);
    cy.get("#user_password").type("trailmix123");
    cy.get("#user_password_confirmation").type("trailmix123");
    cy.contains("input", "Sign up").click();
    cy.visit("/account/edit");
    cy.get("#user_postal_code").type("12345");
    cy.contains("input", "Save address").click();
    cy.contains("Postal code must be a valid Canadian postal code").should("be.visible");
  });
});
