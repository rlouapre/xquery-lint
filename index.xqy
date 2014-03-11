xquery version "1.0-ml";

import module namespace lint = "http://github.com/robwhitby/xquery-lint" at "src/lint.xqy";
declare default function namespace "http://github.com/robwhitby/xquery-lint";

declare private variable $USE-MODULES-DB := (xdmp:modules-database() ne 0);

declare variable $dir as xs:string? := xdmp:get-request-field("dir");

declare variable $file as xs:string? := xdmp:get-request-field("file");

declare variable $debug as xs:boolean := xs:boolean(xdmp:get-request-field("debug", "false"));

declare variable $format as xs:string := xdmp:get-request-field("format", "xml");

if ($dir or $USE-MODULES-DB) then
  lint:process($dir, $debug, $format)
else
  <error/>