// Sign-up / login: happy and unhappy paths. Requires `rails db:seed` first.
describe("Sign-up and login", () => {
  const stamp = Date.now();
  const user = { username: `camper_${stamp}`, email: `camper_${stamp}@example.com`, password: "trailmix123" };

  function signUp(u) {
    cy.visit("/users/sign_up");
    cy.get("#user_username").type(u.username);
    cy.get("#user_email").type(u.email);
    cy.get("#user_password").type(u.password);
    cy.get("#user_password_confirmation").type(u.password);
    cy.contains("input", "Sign up").click();
  }

  it("signs up, logs out and logs back in with the username (happy path)", () => {
    signUp(user);
    cy.contains("Log out").should("exist");
    cy.contains("Log out").click();
    cy.visit("/users/sign_in");
    cy.get("#user_login").type(user.username);
    cy.get("#user_password").type(user.password);
    cy.contains("input", "Log in").click();
    cy.contains("Log out").should("exist");
  });

  it("rejects a duplicate username (unhappy path)", () => {
    const dup = { username: `dup_${stamp}`, email: `dup_${stamp}@example.com`, password: "trailmix123" };
    signUp(dup);
    cy.contains("Log out").click();
    signUp({ ...dup, email: `dup2_${stamp}@example.com` });
    cy.contains("Username has already been taken").should("be.visible");
  });

  it("rejects a short password and mismatched confirmation (unhappy path)", () => {
    cy.visit("/users/sign_up");
    cy.get("#user_username").type(`short_${stamp}`);
    cy.get("#user_email").type(`short_${stamp}@example.com`);
    cy.get("#user_password").type("abc");
    cy.get("#user_password_confirmation").type("xyz");
    cy.contains("input", "Sign up").click();
    cy.contains("Password is too short").should("be.visible");
    cy.contains("Password confirmation doesn't match").should("be.visible");
  });

  it("shows an error for incorrect credentials (unhappy path)", () => {
    cy.visit("/users/sign_in");
    cy.get("#user_login").type("nobody");
    cy.get("#user_password").type("wrongpassword");
    cy.contains("input", "Log in").click();
    cy.contains("Invalid Login or password").should("be.visible");
  });
});
