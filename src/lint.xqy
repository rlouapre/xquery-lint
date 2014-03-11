xquery version "1.0-ml";

module namespace lint = "http://github.com/robwhitby/xquery-lint";
(:declare default element namespace "http://github.com/robwhitby/xquery-lint";:)

(:import module namespace parser = "XQueryML10" at "parsers/XQueryML10.xq";:)
import module namespace parser = "xquery-30" at "parsers/xquery-30.xqy";
import module namespace rules = "http://github.com/robwhitby/xquery-lint/rules" at "rules.xqy";
import module namespace modules-fs = "http://github.com/robwhitby/xquery-lint/modules-fs" at "modules-filesystem.xqy";

declare function process($dir as xs:string, $debug as xs:boolean, $format as xs:string) {
  let $lints :=
    element { xs:QName("lint:lints") } {
    for $module in modules-fs:get-modules($dir, ())
      return process($module, $debug)
  }
  return transform($lints, $format)
}; 

declare private function transform(
  $el as element(),
  $format as xs:string
) as document-node()
{
(:  if ($format eq "text") then xdmp:set-response-content-type("text/plain") else (),:)
  if ($format eq "json") then xdmp:set-response-content-type("application/json") else (),
  if ($format ne "xml")
  then
    xdmp:xslt-invoke(fn:concat("output/", $format, ".xsl"), $el)
  else document { $el }
};

declare function process($filepath as xs:string) 
as element(lint:lint) 
{
	process($filepath, fn:false())
};

declare function process($filepath as xs:string, $debug as xs:boolean) 
as element(lint:lint)
{
	let $ast := parse($filepath)
	return
	 element { xs:QName("lint:lint") } {
	   attribute src {$filepath},
  	typeswitch($ast)
      case element(XQuery)
      return
          (apply-rule($ast, $rules:rules), 
          if ($debug) then $ast else ())
      default
        return parse-error($ast)
	 }
};

declare private function parse-error($error as element(ERROR)) as element(lint:error) {
  let $_ := xdmp:log($error/node())
  return
    element { xs:QName("lint:error") }
    {$error/node()}
};

declare private function parse($module-path as xs:string) 
as item()* (:as element(XQuery)?:)
{
  let $source := fn:string(xdmp:filesystem-file($module-path))
  where $source
  return parser:parse-XQuery($source)
};

declare private function apply-rule($ast as element(XQuery), $rule as element(rule))
as element(lint:rule)?
{
	let $matches := xdmp:value(fn:concat("$ast", $rule/test))
	where $matches
	return
	 element { xs:QName("lint:rule") } {
	   attribute name {$rule/name},
	   attribute level {$rule/level},
	   attribute occurrences {fn:count($matches)},
    for $m in $matches
      return 
        element { xs:QName("lint:source") } {$m/ancestor-or-self::FunctionDecl/fn:string()}
	 }

(:<rule name="{$rule/name}" level="{$rule/level}" occurrences="{fn:count($matches)}">
		{
			for $m in $matches
			return <source>{$m/ancestor-or-self::FunctionDecl/fn:string()}</source>
		}
		</rule>
:)
};

