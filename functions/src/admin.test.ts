import assert from "node:assert/strict";
import {test} from "node:test";

import {generateDoctorCode, roleOf} from "./admin";

test("doctor codes are DR- plus 6 unambiguous characters", () => {
  for (let i = 0; i < 200; i++) {
    assert.match(generateDoctorCode(), /^DR-[A-HJ-NP-Z2-9]{6}$/);
  }
  assert.equal(generateDoctorCode(() => 0), "DR-AAAAAA");
  assert.equal(generateDoctorCode(() => 0.9999), "DR-999999");
});

test("roleOf defaults to owner", () => {
  assert.equal(roleOf(undefined), "owner");
  assert.equal(roleOf({}), "owner");
  assert.equal(roleOf({role: "superuser"}), "owner");
  assert.equal(roleOf({role: "doctor"}), "doctor");
  assert.equal(roleOf({role: "admin"}), "admin");
});
