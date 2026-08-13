export function buildUsersMapRequestParams(extensionParams = {}) {
  return { ...extensionParams, period: "location" };
}
