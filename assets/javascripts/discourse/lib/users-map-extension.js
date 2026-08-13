export function normalizeUsersMapRequestParams(extensionParams) {
  if (
    !extensionParams ||
    typeof extensionParams !== "object" ||
    Array.isArray(extensionParams)
  ) {
    return {};
  }

  return { ...extensionParams };
}

export function buildUsersMapRequestParams(extensionParams) {
  return {
    ...normalizeUsersMapRequestParams(extensionParams),
    period: "location",
  };
}
