import DiscourseRecommended from "@discourse/lint-configs/eslint";

export default [
  ...DiscourseRecommended,
  {
    rules: {
      "discourse/ui-kit-imports": "off",
      "ember/no-classic-components": "off",
      "ember/require-tagless-components": "off",
      "discourse/no-unnecessary-tracked": "off",
      "ember/no-side-effects": "off",
      "no-useless-assignment": "off",
      "ember/template-no-template-lint-directives": "off",
      "ember/template-link-rel-noopener": "off",
      "ember/route-path-style": "off",
      "discourse/discourse-common-imports": "off",
      "qunit/no-assert-equal": "off",
      "qunit/no-loose-assertions": "off",
    },
  },
];
