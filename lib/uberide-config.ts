export const OPENFREEMAP_STYLE = "https://tiles.openfreemap.org/styles/liberty";
export const OPENFREEMAP_HOME = "https://openfreemap.org";
export const UBER_DEVELOPERS = "https://developer.uber.com";

export type SearchChoice = {
  label: string;
  detail: string;
};

export const SEARCH_CHOICES: SearchChoice[] = [
  { label: "Current location", detail: "Use the device location when permitted" },
  { label: "Airport pickup", detail: "Save a pickup point for your next ride" },
  { label: "Central station", detail: "Choose a common destination" },
];

export function filterSearchChoices(query: string): SearchChoice[] {
  const normalized = query.trim().toLowerCase();
  if (!normalized) return SEARCH_CHOICES;
  return SEARCH_CHOICES.filter((choice) =>
    `${choice.label} ${choice.detail}`.toLowerCase().includes(normalized),
  );
}

export function hasUsableDriverCoordinates(payload: unknown): boolean {
  if (!payload || typeof payload !== "object") return false;
  const vehicle = (payload as { vehicle?: unknown }).vehicle;
  if (!vehicle || typeof vehicle !== "object") return false;
  const location = (vehicle as { location?: unknown }).location;
  if (!location || typeof location !== "object") return false;
  const { latitude, longitude } = location as { latitude?: unknown; longitude?: unknown };
  return (
    typeof latitude === "number" &&
    Number.isFinite(latitude) &&
    latitude >= -90 &&
    latitude <= 90 &&
    typeof longitude === "number" &&
    Number.isFinite(longitude) &&
    longitude >= -180 &&
    longitude <= 180
  );
}
