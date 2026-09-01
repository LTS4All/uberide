import { describe, expect, it } from "vitest";

import {
  filterSearchChoices,
  hasUsableDriverCoordinates,
  OPENFREEMAP_STYLE,
} from "../lib/uberide-config";

describe("Uberide integration configuration", () => {
  it("uses the official OpenFreeMap Liberty style", () => {
    expect(OPENFREEMAP_STYLE).toBe("https://tiles.openfreemap.org/styles/liberty");
  });

  it("filters saved choices case-insensitively", () => {
    expect(filterSearchChoices("airport").map((choice) => choice.label)).toEqual(["Airport pickup"]);
    expect(filterSearchChoices("  CURRENT  ").map((choice) => choice.label)).toEqual(["Current location"]);
    expect(filterSearchChoices("not a place")).toHaveLength(0);
  });

  it("accepts only finite, valid driver coordinates", () => {
    expect(
      hasUsableDriverCoordinates({ vehicle: { location: { latitude: 51.5, longitude: -0.12 } } }),
    ).toBe(true);
    expect(
      hasUsableDriverCoordinates({ vehicle: { location: { latitude: 91, longitude: -0.12 } } }),
    ).toBe(false);
    expect(hasUsableDriverCoordinates({ vehicle: {} })).toBe(false);
    expect(hasUsableDriverCoordinates(null)).toBe(false);
  });
});
