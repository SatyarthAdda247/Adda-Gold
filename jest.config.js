module.exports = {
  preset: "jest-expo",
  testMatch: ["**/__tests__/**/*.(test|spec).ts?(x)"],
  setupFilesAfterEnv: ["<rootDir>/jest.setup.ts"],
  moduleNameMapper: {
    "^@app/(.*)$": "<rootDir>/app/$1",
    "^@components/(.*)$": "<rootDir>/app/components/$1",
    "^@screens/(.*)$": "<rootDir>/app/screens/$1",
    "^@services/(.*)$": "<rootDir>/app/services/$1",
    "^@store/(.*)$": "<rootDir>/app/store/$1",
    "^@theme/(.*)$": "<rootDir>/app/theme/$1",
    "^@mock/(.*)$": "<rootDir>/mock/$1"
  },
  transformIgnorePatterns: [
    "node_modules/(?!((jest-)?react-native|@react-native|expo|@expo|@react-navigation)/)",
  ],
};

