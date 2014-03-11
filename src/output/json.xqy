xquery version "1.0-ml";

module namespace lint-json = "http://github.com/robwhitby/xquery-lint/json";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace lint = "http://github.com/robwhitby/xquery-lint";

declare function to-json(
  $node as node()
) as xs:string
{
  let $custom :=
    let $config := json:config("custom")
    return (
      map:put($config, "array-element-names", ("lint", "source", "rule")),
      map:put($config, "element-namespace", "http://github.com/robwhitby/xquery-lint"),
      $config)
  return 
    json:transform-to-json($node, $custom)
};

