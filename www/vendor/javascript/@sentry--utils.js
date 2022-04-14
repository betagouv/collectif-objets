export{forget}from"./async.js";import{f as r,c as t}from"../_/3099f0e6.js";export{a as addNonEnumerableProperty,c as convertToPlainObject,d as dropUndefinedKeys,e as extractExceptionKeysForMessage,f as fill,g as getLocationHref,b as getOriginalFunction,h as htmlTreeAsString,m as markFunctionWrapped,o as objectify,u as urlEncode}from"../_/3099f0e6.js";import{__extends as n,__read as s,__values as v,__assign as p,__spread as y}from"tslib";import{I as _,l as S,C as w}from"../_/7dad6fa3.js";export{C as CONSOLE_LEVELS,c as consoleSandbox,l as logger}from"../_/7dad6fa3.js";import{g as E,d as x,i as O}from"../_/36d0f3aa.js";export{d as dynamicRequire,g as getGlobalObject,a as getGlobalSingleton,b as isBrowserBundle,i as isNodeEnv,l as loadModule}from"../_/36d0f3aa.js";import{isInstanceOf as j,isString as P,isNaN as D,isError as R,isEvent as k,isSyntheticEvent as N,isThenable as F,isPrimitive as H}from"./is.js";export{isDOMError,isDOMException,isElement,isError,isErrorEvent,isEvent,isInstanceOf,isNaN,isPlainObject,isPrimitive,isRegExp,isString,isSyntheticEvent,isThenable}from"./is.js";import{supportsNativeFetch as I,supportsHistory as T}from"./supports.js";export{isNativeFetch,supportsDOMError,supportsDOMException,supportsErrorEvent,supportsFetch,supportsHistory,supportsNativeFetch,supportsReferrerPolicy,supportsReportingObserver}from"./supports.js";export{addContextToFrame,addExceptionMechanism,addExceptionTypeValue,checkOrSetAlreadyCaught,getEventDescription,parseSemver,parseUrl,stripUrlQueryAndFragment,uuid4}from"./misc.js";export{basename,dirname,isAbsolute,join,normalizePath,relative,resolve}from"./path.js";import{Severity as M}from"@sentry/types";export{escapeStringForRegex,isMatchingPattern,safeJoin,snipLine,truncate}from"./string.js";var z=Object.setPrototypeOf||({__proto__:[]}instanceof Array?setProtoOf:mixinProperties);function setProtoOf(e,r){e.__proto__=r;return e}function mixinProperties(e,r){for(var t in r)Object.prototype.hasOwnProperty.call(e,t)||(e[t]=r[t]);return e}var L=function(e){n(SentryError,e);function SentryError(r){var t=this.constructor;var n=e.call(this,r)||this;n.message=r;n.name=t.prototype.constructor.name;z(n,t.prototype);return n}return SentryError}(Error);var A=/^(?:(\w+):)\/\/(?:(\w+)(?::(\w+))?@)([\w.-]+)(?::(\d+))?\/(.+)/;function isValidProtocol(e){return"http"===e||"https"===e}
/**
 * Renders the string representation of this Dsn.
 *
 * By default, this will render the public representation without the password
 * component. To get the deprecated private representation, set `withPassword`
 * to true.
 *
 * @param withPassword When set to true, the password will be included.
 */function dsnToString(e,r){void 0===r&&(r=false);var t=e.host,n=e.path,i=e.pass,o=e.port,a=e.projectId,s=e.protocol,u=e.publicKey;return s+"://"+u+(r&&i?":"+i:"")+"@"+t+(o?":"+o:"")+"/"+(n?n+"/":n)+a}function dsnFromString(e){var r=A.exec(e);if(!r)throw new L("Invalid Sentry Dsn: "+e);var t=s(r.slice(1),6),n=t[0],i=t[1],o=t[2],a=void 0===o?"":o,u=t[3],c=t[4],f=void 0===c?"":c,l=t[5];var d="";var v=l;var p=v.split("/");if(p.length>1){d=p.slice(0,-1).join("/");v=p.pop()}if(v){var m=v.match(/^\d+/);m&&(v=m[0])}return dsnFromComponents({host:u,pass:a,path:d,projectId:v,port:f,protocol:n,publicKey:i})}function dsnFromComponents(e){"user"in e&&!("publicKey"in e)&&(e.publicKey=e.user);return{user:e.publicKey||"",protocol:e.protocol,publicKey:e.publicKey||"",pass:e.pass||"",host:e.host,port:e.port||"",path:e.path||"",projectId:e.projectId}}function validateDsn(e){if(_){var r=e.port,t=e.projectId,n=e.protocol;var i=["protocol","publicKey","host","projectId"];i.forEach((function(r){if(!e[r])throw new L("Invalid Sentry Dsn: "+r+" missing")}));if(!t.match(/^\d+$/))throw new L("Invalid Sentry Dsn: Invalid projectId "+t);if(!isValidProtocol(n))throw new L("Invalid Sentry Dsn: Invalid protocol "+n);if(r&&isNaN(parseInt(r,10)))throw new L("Invalid Sentry Dsn: Invalid port "+r);return true}}function makeDsn(e){var r="string"===typeof e?dsnFromString(e):dsnFromComponents(e);validateDsn(r);return r}var U=["fatal","error","warning","log","info","debug","critical"];var B=50;function createStackParser(){var e=[];for(var r=0;r<arguments.length;r++)e[r]=arguments[r];var t=e.sort((function(e,r){return e[0]-r[0]})).map((function(e){return e[1]}));return function(e,r){var n,i,o,a;void 0===r&&(r=0);var s=[];try{for(var u=v(e.split("\n").slice(r)),c=u.next();!c.done;c=u.next()){var f=c.value;try{for(var l=(o=void 0,v(t)),d=l.next();!d.done;d=l.next()){var p=d.value;var m=p(f);if(m){s.push(m);break}}}catch(e){o={error:e}}finally{try{d&&!d.done&&(a=l.return)&&a.call(l)}finally{if(o)throw o.error}}}}catch(e){n={error:e}}finally{try{c&&!c.done&&(i=u.return)&&i.call(u)}finally{if(n)throw n.error}}return stripSentryFramesAndReverse(s)}}function stripSentryFramesAndReverse(e){if(!e.length)return[];var r=e;var t=r[0].function||"";var n=r[r.length-1].function||"";-1===t.indexOf("captureMessage")&&-1===t.indexOf("captureException")||(r=r.slice(1));-1!==n.indexOf("sentryWrapped")&&(r=r.slice(0,-1));return r.slice(0,B).map((function(e){return p(p({},e),{filename:e.filename||r[0].filename,function:e.function||"?"})})).reverse()}var K="<anonymous>";function getFunctionName(e){try{return e&&"function"===typeof e&&e.name||K}catch(e){return K}}var q=E();var J={};var W={};function instrument(e){if(!W[e]){W[e]=true;switch(e){case"console":instrumentConsole();break;case"dom":instrumentDOM();break;case"xhr":instrumentXHR();break;case"fetch":instrumentFetch();break;case"history":instrumentHistory();break;case"error":instrumentError();break;case"unhandledrejection":instrumentUnhandledRejection();break;default:_&&S.warn("unknown instrumentation type:",e);return}}}function addInstrumentationHandler(e,r){J[e]=J[e]||[];J[e].push(r);instrument(e)}function triggerHandlers(e,r){var t,n;if(e&&J[e])try{for(var i=v(J[e]||[]),o=i.next();!o.done;o=i.next()){var a=o.value;try{a(r)}catch(r){_&&S.error("Error while triggering instrumentation handler.\nType: "+e+"\nName: "+getFunctionName(a)+"\nError:",r)}}}catch(e){t={error:e}}finally{try{o&&!o.done&&(n=i.return)&&n.call(i)}finally{if(t)throw t.error}}}function instrumentConsole(){"console"in q&&w.forEach((function(e){e in q.console&&r(q.console,e,(function(r){return function(){var t=[];for(var n=0;n<arguments.length;n++)t[n]=arguments[n];triggerHandlers("console",{args:t,level:e});r&&r.apply(q.console,t)}}))}))}function instrumentFetch(){I()&&r(q,"fetch",(function(e){return function(){var r=[];for(var t=0;t<arguments.length;t++)r[t]=arguments[t];var n={args:r,fetchData:{method:getFetchMethod(r),url:getFetchUrl(r)},startTimestamp:Date.now()};triggerHandlers("fetch",p({},n));return e.apply(q,r).then((function(e){triggerHandlers("fetch",p(p({},n),{endTimestamp:Date.now(),response:e}));return e}),(function(e){triggerHandlers("fetch",p(p({},n),{endTimestamp:Date.now(),error:e}));throw e}))}}))}
/* eslint-disable @typescript-eslint/no-unsafe-member-access */function getFetchMethod(e){void 0===e&&(e=[]);return"Request"in q&&j(e[0],Request)&&e[0].method?String(e[0].method).toUpperCase():e[1]&&e[1].method?String(e[1].method).toUpperCase():"GET"}function getFetchUrl(e){void 0===e&&(e=[]);return"string"===typeof e[0]?e[0]:"Request"in q&&j(e[0],Request)?e[0].url:String(e[0])}
/* eslint-enable @typescript-eslint/no-unsafe-member-access */function instrumentXHR(){if("XMLHttpRequest"in q){var e=XMLHttpRequest.prototype;r(e,"open",(function(e){return function(){var t=[];for(var n=0;n<arguments.length;n++)t[n]=arguments[n];var i=this;var o=t[1];var a=i.__sentry_xhr__={method:P(t[0])?t[0].toUpperCase():t[0],url:t[1]};P(o)&&"POST"===a.method&&o.match(/sentry_key/)&&(i.__sentry_own_request__=true);var onreadystatechangeHandler=function(){if(4===i.readyState){try{a.status_code=i.status}catch(e){}triggerHandlers("xhr",{args:t,endTimestamp:Date.now(),startTimestamp:Date.now(),xhr:i})}};"onreadystatechange"in i&&"function"===typeof i.onreadystatechange?r(i,"onreadystatechange",(function(e){return function(){var r=[];for(var t=0;t<arguments.length;t++)r[t]=arguments[t];onreadystatechangeHandler();return e.apply(i,r)}})):i.addEventListener("readystatechange",onreadystatechangeHandler);return e.apply(i,t)}}));r(e,"send",(function(e){return function(){var r=[];for(var t=0;t<arguments.length;t++)r[t]=arguments[t];this.__sentry_xhr__&&void 0!==r[0]&&(this.__sentry_xhr__.body=r[0]);triggerHandlers("xhr",{args:r,startTimestamp:Date.now(),xhr:this});return e.apply(this,r)}}))}}var V;function instrumentHistory(){if(T()){var e=q.onpopstate;q.onpopstate=function(){var r=[];for(var t=0;t<arguments.length;t++)r[t]=arguments[t];var n=q.location.href;var i=V;V=n;triggerHandlers("history",{from:i,to:n});if(e)try{return e.apply(this,r)}catch(e){}};r(q.history,"pushState",historyReplacementFunction);r(q.history,"replaceState",historyReplacementFunction)}function historyReplacementFunction(e){return function(){var r=[];for(var t=0;t<arguments.length;t++)r[t]=arguments[t];var n=r.length>2?r[2]:void 0;if(n){var i=V;var o=String(n);V=o;triggerHandlers("history",{from:i,to:o})}return e.apply(this,r)}}}var X=1e3;var G;var $;
/**
 * Decide whether the current event should finish the debounce of previously captured one.
 * @param previous previously captured event
 * @param current event to be captured
 */function shouldShortcircuitPreviousDebounce(e,r){if(!e)return true;if(e.type!==r.type)return true;try{if(e.target!==r.target)return true}catch(e){}return false}
/**
 * Decide whether an event should be captured.
 * @param event event to be captured
 */function shouldSkipDOMEvent(e){if("keypress"!==e.type)return false;try{var r=e.target;if(!r||!r.tagName)return true;if("INPUT"===r.tagName||"TEXTAREA"===r.tagName||r.isContentEditable)return false}catch(e){}return true}
/**
 * Wraps addEventListener to capture UI breadcrumbs
 * @param handler function that will be triggered
 * @param globalListener indicates whether event was captured by the global event listener
 * @returns wrapped breadcrumb events handler
 * @hidden
 */function makeDOMEventHandler(e,r){void 0===r&&(r=false);return function(t){if(t&&$!==t&&!shouldSkipDOMEvent(t)){var n="keypress"===t.type?"input":t.type;if(void 0===G){e({event:t,name:n,global:r});$=t}else if(shouldShortcircuitPreviousDebounce($,t)){e({event:t,name:n,global:r});$=t}clearTimeout(G);G=q.setTimeout((function(){G=void 0}),X)}}}function instrumentDOM(){if("document"in q){var e=triggerHandlers.bind(null,"dom");var t=makeDOMEventHandler(e,true);q.document.addEventListener("click",t,false);q.document.addEventListener("keypress",t,false);["EventTarget","Node"].forEach((function(t){var n=q[t]&&q[t].prototype;if(n&&n.hasOwnProperty&&n.hasOwnProperty("addEventListener")){r(n,"addEventListener",(function(r){return function(t,n,i){if("click"===t||"keypress"==t)try{var o=this;var a=o.__sentry_instrumentation_handlers__=o.__sentry_instrumentation_handlers__||{};var s=a[t]=a[t]||{refCount:0};if(!s.handler){var u=makeDOMEventHandler(e);s.handler=u;r.call(this,t,u,i)}s.refCount+=1}catch(e){}return r.call(this,t,n,i)}}));r(n,"removeEventListener",(function(e){return function(r,t,n){if("click"===r||"keypress"==r)try{var i=this;var o=i.__sentry_instrumentation_handlers__||{};var a=o[r];if(a){a.refCount-=1;if(a.refCount<=0){e.call(this,r,a.handler,n);a.handler=void 0;delete o[r]}0===Object.keys(o).length&&delete i.__sentry_instrumentation_handlers__}}catch(e){}return e.call(this,r,t,n)}}))}}))}}var Q=null;function instrumentError(){Q=q.onerror;q.onerror=function(e,r,t,n,i){triggerHandlers("error",{column:n,error:i,line:t,msg:e,url:r});return!!Q&&Q.apply(this,arguments)}}var Y=null;function instrumentUnhandledRejection(){Y=q.onunhandledrejection;q.onunhandledrejection=function(e){triggerHandlers("unhandledrejection",e);return!Y||Y.apply(this,arguments)}}
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-explicit-any */function memoBuilder(){var e="function"===typeof WeakSet;var r=e?new WeakSet:[];function memoize(t){if(e){if(r.has(t))return true;r.add(t);return false}for(var n=0;n<r.length;n++){var i=r[n];if(i===t)return true}r.push(t);return false}function unmemoize(t){if(e)r.delete(t);else for(var n=0;n<r.length;n++)if(r[n]===t){r.splice(n,1);break}}return[memoize,unmemoize]}
/**
 * Recursively normalizes the given object.
 *
 * - Creates a copy to prevent original input mutation
 * - Skips non-enumerable properties
 * - When stringifying, calls `toJSON` if implemented
 * - Removes circular references
 * - Translates non-serializable values (`undefined`/`NaN`/functions) to serializable format
 * - Translates known global objects/classes to a string representations
 * - Takes care of `Error` object serialization
 * - Optionally limits depth of final output
 * - Optionally limits number of properties/elements included in any single object/array
 *
 * @param input The object to be normalized.
 * @param depth The max depth to which to normalize the object. (Anything deeper stringified whole.)
 * @param maxProperties The max number of elements or properties to be included in any single array or
 * object in the normallized output..
 * @returns A normalized version of the object, or `"**non-serializable**"` if any errors are thrown during normalization.
 */function normalize(e,r,t){void 0===r&&(r=Infinity);void 0===t&&(t=Infinity);try{return visit("",e,r,t)}catch(e){return{ERROR:"**non-serializable** ("+e+")"}}}function normalizeToSize(e,r,t){void 0===r&&(r=3);void 0===t&&(t=102400);var n=normalize(e,r);return jsonSize(n)>t?normalizeToSize(e,r-1,t):n}
/**
 * Visits a node to perform normalization on it
 *
 * @param key The key corresponding to the given node
 * @param value The node to be visited
 * @param depth Optional number indicating the maximum recursion depth
 * @param maxProperties Optional maximum number of properties/elements included in any single object/array
 * @param memo Optional Memo class handling decycling
 */function visit(e,r,n,i,o){void 0===n&&(n=Infinity);void 0===i&&(i=Infinity);void 0===o&&(o=memoBuilder());var a=s(o,2),u=a[0],c=a[1];var f=r;if(f&&"function"===typeof f.toJSON)try{return f.toJSON()}catch(e){}if(null===r||["number","boolean","string"].includes(typeof r)&&!D(r))return r;var l=stringifyValue(e,r);if(!l.startsWith("[object "))return l;if(0===n)return l.replace("object ","");if(u(r))return"[Circular ~]";var d=Array.isArray(r)?[]:{};var v=0;var p=R(r)||k(r)?t(r):r;for(var m in p)if(Object.prototype.hasOwnProperty.call(p,m)){if(v>=i){d[m]="[MaxProperties ~]";break}var h=p[m];d[m]=visit(m,h,n-1,i,o);v+=1}c(r);return d}
/**
 * Stringify the given value. Handles various known special values and types.
 *
 * Not meant to be used on simple primitives which already have a string representation, as it will, for example, turn
 * the number 1231 into "[Object Number]", nor on `null`, as it will throw.
 *
 * @param value The value to stringify
 * @returns A stringified representation of the given value
 */function stringifyValue(e,r){try{return"domain"===e&&r&&"object"===typeof r&&r._events?"[Domain]":"domainEmitter"===e?"[DomainEmitter]":"undefined"!==typeof global&&r===global?"[Global]":"undefined"!==typeof window&&r===window?"[Window]":"undefined"!==typeof document&&r===document?"[Document]":N(r)?"[SyntheticEvent]":"number"===typeof r&&r!==r?"[NaN]":void 0===r?"[undefined]":"function"===typeof r?"[Function: "+getFunctionName(r)+"]":"symbol"===typeof r?"["+String(r)+"]":"bigint"===typeof r?"[BigInt: "+String(r)+"]":"[object "+Object.getPrototypeOf(r).constructor.name+"]"}catch(e){return"**non-serializable** ("+e+")"}}function utf8Length(e){return~-encodeURI(e).split(/%..|./).length}function jsonSize(e){return utf8Length(JSON.stringify(e))}
/* eslint-disable @typescript-eslint/explicit-function-return-type */
/**
 * Creates a resolved sync promise.
 *
 * @param value the value to resolve the promise with
 * @returns the resolved sync promise
 */function resolvedSyncPromise(e){return new Z((function(r){r(e)}))}
/**
 * Creates a rejected sync promise.
 *
 * @param value the value to reject the promise with
 * @returns the rejected sync promise
 */function rejectedSyncPromise(e){return new Z((function(r,t){t(e)}))}var Z=function(){function SyncPromise(e){var r=this;this._state=0;this._handlers=[];this._resolve=function(e){r._setResult(1,e)};this._reject=function(e){r._setResult(2,e)};this._setResult=function(e,t){if(0===r._state)if(F(t))void t.then(r._resolve,r._reject);else{r._state=e;r._value=t;r._executeHandlers()}};this._executeHandlers=function(){if(0!==r._state){var e=r._handlers.slice();r._handlers=[];e.forEach((function(e){if(!e[0]){1===r._state&&e[1](r._value);2===r._state&&e[2](r._value);e[0]=true}}))}};try{e(this._resolve,this._reject)}catch(e){this._reject(e)}}SyncPromise.prototype.then=function(e,r){var t=this;return new SyncPromise((function(n,i){t._handlers.push([false,function(r){if(e)try{n(e(r))}catch(e){i(e)}else n(r)},function(e){if(r)try{n(r(e))}catch(e){i(e)}else i(e)}]);t._executeHandlers()}))};SyncPromise.prototype.catch=function(e){return this.then((function(e){return e}),e)};SyncPromise.prototype.finally=function(e){var r=this;return new SyncPromise((function(t,n){var i;var o;return r.then((function(r){o=false;i=r;e&&e()}),(function(r){o=true;i=r;e&&e()})).then((function(){o?n(i):t(i)}))}))};return SyncPromise}();
/**
 * Creates an new PromiseBuffer object with the specified limit
 * @param limit max number of promises that can be stored in the buffer
 */function makePromiseBuffer(e){var r=[];function isReady(){return void 0===e||r.length<e}
/**
     * Remove a promise from the queue.
     *
     * @param task Can be any PromiseLike<T>
     * @returns Removed promise.
     */function remove(e){return r.splice(r.indexOf(e),1)[0]}
/**
     * Add a promise (representing an in-flight action) to the queue, and set it to remove itself on fulfillment.
     *
     * @param taskProducer A function producing any PromiseLike<T>; In previous versions this used to be `task:
     *        PromiseLike<T>`, but under that model, Promises were instantly created on the call-site and their executor
     *        functions therefore ran immediately. Thus, even if the buffer was full, the action still happened. By
     *        requiring the promise to be wrapped in a function, we can defer promise creation until after the buffer
     *        limit check.
     * @returns The original promise.
     */function add(e){if(!isReady())return rejectedSyncPromise(new L("Not adding Promise due to buffer limit reached."));var t=e();-1===r.indexOf(t)&&r.push(t);void t.then((function(){return remove(t)})).then(null,(function(){return remove(t).then(null,(function(){}))}));return t}
/**
     * Wait for all promises in the queue to resolve or for timeout to expire, whichever comes first.
     *
     * @param timeout The time, in ms, after which to resolve to `false` if the queue is still non-empty. Passing `0` (or
     * not passing anything) will make the promise wait as long as it takes for the queue to drain before resolving to
     * `true`.
     * @returns A promise which will resolve to `true` if the queue is already empty or drains before the timeout, and
     * `false` otherwise
     */function drain(e){return new Z((function(t,n){var i=r.length;if(!i)return t(true);var o=setTimeout((function(){e&&e>0&&t(false)}),e);r.forEach((function(e){void resolvedSyncPromise(e).then((function(){if(!--i){clearTimeout(o);t(true)}}),n)}))}))}return{$:r,add:add,drain:drain}}function isSupportedSeverity(e){return-1!==U.indexOf(e)}
/**
 * Converts a string-based level into a {@link Severity}.
 *
 * @param level string representation of Severity
 * @returns Severity
 */function severityFromString(e){return"warn"===e?M.Warning:isSupportedSeverity(e)?e:M.Log}
/**
 * Converts an HTTP status code to sentry status {@link EventStatus}.
 *
 * @param code number HTTP status code
 * @returns EventStatus
 */function eventStatusFromHttpCode(e){return e>=200&&e<300?"success":429===e?"rate_limit":e>=400&&e<500?"invalid":e>=500?"failed":"unknown"}var ee={nowSeconds:function(){return Date.now()/1e3}};function getBrowserPerformance(){var e=E().performance;if(e&&e.now){var r=Date.now()-e.now();return{now:function(){return e.now()},timeOrigin:r}}}function getNodePerformance(){try{var e=x(module,"perf_hooks");return e.performance}catch(e){return}}var re=O()?getNodePerformance():getBrowserPerformance();var te=void 0===re?ee:{nowSeconds:function(){return(re.timeOrigin+re.now())/1e3}};var ne=ee.nowSeconds.bind(ee);var ie=te.nowSeconds.bind(te);var oe=ie;var ae=void 0!==re;var se;var ue=function(){var e=E().performance;if(e&&e.now){var r=36e5;var t=e.now();var n=Date.now();var i=e.timeOrigin?Math.abs(e.timeOrigin+t-n):r;var o=i<r;var a=e.timing&&e.timing.navigationStart;var s="number"===typeof a;var u=s?Math.abs(a+t-n):r;var c=u<r;if(o||c){if(i<=u){se="timeOrigin";return e.timeOrigin}se="navigationStart";return a}se="dateNow";return n}se="none"}();var ce=new RegExp("^[ \\t]*([0-9a-f]{32})?-?([0-9a-f]{16})?-?([01])?[ \\t]*$");
/**
 * Extract transaction context data from a `sentry-trace` header.
 *
 * @param traceparent Traceparent string
 *
 * @returns Object containing data from the header, or undefined if traceparent string is malformed
 */function extractTraceparentData(e){var r=e.match(ce);if(r){var t=void 0;"1"===r[3]?t=true:"0"===r[3]&&(t=false);return{traceId:r[1],parentSampled:t,parentSpanId:r[2]}}}function createEnvelope(e,r){void 0===r&&(r=[]);return[e,r]}function addItemToEnvelope(e,r){var t=s(e,2),n=t[0],i=t[1];return[n,y(i,[r])]}function getEnvelopeType(e){var r=s(e,2),t=s(r[1],1),n=s(t[0],1),i=n[0];return i.type}function serializeEnvelope(e){var r=s(e,2),t=r[0],n=r[1];var i=JSON.stringify(t);return n.reduce((function(e,r){var t=s(r,2),n=t[0],i=t[1];var o=H(i)?String(i):JSON.stringify(i);return e+"\n"+JSON.stringify(n)+"\n"+o}),i)}
/**
 * Creates client report envelope
 * @param discarded_events An array of discard events
 * @param dsn A DSN that can be set on the header. Optional.
 */function createClientReportEnvelope(e,r,t){var n=[{type:"client_report"},{timestamp:t||ne(),discarded_events:e}];return createEnvelope(r?{dsn:r}:{},[n])}var fe=6e4;
/**
 * Extracts Retry-After value from the request header or returns default value
 * @param header string representation of 'Retry-After' header
 * @param now current unix timestamp
 *
 */function parseRetryAfterHeader(e,r){void 0===r&&(r=Date.now());var t=parseInt(""+e,10);if(!isNaN(t))return 1e3*t;var n=Date.parse(""+e);return isNaN(n)?fe:n-r}function disabledUntil(e,r){return e[r]||e.all||0}function isRateLimited(e,r,t){void 0===t&&(t=Date.now());return disabledUntil(e,r)>t}function updateRateLimits(e,r,t){var n,i,o,a;void 0===t&&(t=Date.now());var s=p({},e);var u=r["x-sentry-rate-limits"];var c=r["retry-after"];if(u)try{for(var f=v(u.trim().split(",")),l=f.next();!l.done;l=f.next()){var d=l.value;var m=d.split(":",2);var h=parseInt(m[0],10);var y=1e3*(isNaN(h)?60:h);if(m[1])try{for(var g=(o=void 0,v(m[1].split(";"))),_=g.next();!_.done;_=g.next()){var S=_.value;s[S]=t+y}}catch(e){o={error:e}}finally{try{_&&!_.done&&(a=g.return)&&a.call(g)}finally{if(o)throw o.error}}else s.all=t+y}}catch(e){n={error:e}}finally{try{l&&!l.done&&(i=f.return)&&i.call(f)}finally{if(n)throw n.error}}else c&&(s.all=t+parseRetryAfterHeader(c,t));return s}export{fe as DEFAULT_RETRY_AFTER,L as SentryError,U as SeverityLevels,Z as SyncPromise,ce as TRACEPARENT_REGEXP,se as _browserPerformanceTimeOriginMode,addInstrumentationHandler,addItemToEnvelope,ue as browserPerformanceTimeOrigin,createClientReportEnvelope,createEnvelope,createStackParser,ne as dateTimestampInSeconds,disabledUntil,dsnToString,eventStatusFromHttpCode,extractTraceparentData,getEnvelopeType,getFunctionName,isRateLimited,makeDsn,makePromiseBuffer,memoBuilder,normalize,normalizeToSize,parseRetryAfterHeader,rejectedSyncPromise,resolvedSyncPromise,serializeEnvelope,severityFromString,stripSentryFramesAndReverse,ie as timestampInSeconds,oe as timestampWithMs,updateRateLimits,ae as usingPerformanceAPI,visit as walk};

