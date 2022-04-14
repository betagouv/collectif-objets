import{__spread as t,__assign as n}from"tslib";import{getCurrentHub as e}from"@sentry/hub";
/**
 * This calls a function on the current hub.
 * @param method function to call on hub.
 * @param args to pass to function.
 */
function callOnHub(n){var r=[];for(var a=1;a<arguments.length;a++)r[a-1]=arguments[a];var c=e();if(c&&c[n])return c[n].apply(c,t(r));throw new Error("No hub defined or "+n+" was not found on the hub, please open a bug report.")}
/**
 * Captures an exception event and sends it to Sentry.
 *
 * @param exception An exception-like object.
 * @returns The generated eventId.
 */function captureException(t,n){var e=new Error("Sentry syntheticException");return callOnHub("captureException",t,{captureContext:n,originalException:t,syntheticException:e})}
/**
 * Captures a message event and sends it to Sentry.
 *
 * @param message The message to send to Sentry.
 * @param Severity Define the level of the message.
 * @returns The generated eventId.
 */function captureMessage(t,e){var r=new Error(t);var a="string"===typeof e?e:void 0;var c="string"!==typeof e?{captureContext:e}:void 0;return callOnHub("captureMessage",t,a,n({originalException:t,syntheticException:r},c))}
/**
 * Captures a manually created event and sends it to Sentry.
 *
 * @param event The event to send to Sentry.
 * @returns The generated eventId.
 */function captureEvent(t){return callOnHub("captureEvent",t)}
/**
 * Callback to set context information onto the scope.
 * @param callback Callback function that receives Scope.
 */function configureScope(t){callOnHub("configureScope",t)}
/**
 * Records a new breadcrumb which will be attached to future events.
 *
 * Breadcrumbs will be added to subsequent events to provide more context on
 * user's actions prior to an error or crash.
 *
 * @param breadcrumb The breadcrumb to record.
 */function addBreadcrumb(t){callOnHub("addBreadcrumb",t)}
/**
 * Sets context data with the given name.
 * @param name of the context
 * @param context Any kind of data. This data will be normalized.
 */function setContext(t,n){callOnHub("setContext",t,n)}
/**
 * Set an object that will be merged sent as extra data with the event.
 * @param extras Extras object to merge into current context.
 */function setExtras(t){callOnHub("setExtras",t)}
/**
 * Set an object that will be merged sent as tags data with the event.
 * @param tags Tags context object to merge into current context.
 */function setTags(t){callOnHub("setTags",t)}
/**
 * Set key:value that will be sent as extra data with the event.
 * @param key String of extra
 * @param extra Any kind of data. This data will be normalized.
 */function setExtra(t,n){callOnHub("setExtra",t,n)}
/**
 * Set key:value that will be sent as tags data with the event.
 *
 * Can also be used to unset a tag, by passing `undefined`.
 *
 * @param key String key of tag
 * @param value Value of tag
 */function setTag(t,n){callOnHub("setTag",t,n)}
/**
 * Updates user context information for future events.
 *
 * @param user User context object to be set in the current context. Pass `null` to unset the user.
 */function setUser(t){callOnHub("setUser",t)}
/**
 * Creates a new scope with and executes the given operation within.
 * The scope is automatically removed once the operation
 * finishes or throws.
 *
 * This is essentially a convenience function for:
 *
 *     pushScope();
 *     callback();
 *     popScope();
 *
 * @param callback that will be enclosed into push/popScope.
 */function withScope(t){callOnHub("withScope",t)}
/**
 * Calls a function on the latest client. Use this with caution, it's meant as
 * in "internal" helper so we don't need to expose every possible function in
 * the shim. It is not guaranteed that the client actually implements the
 * function.
 *
 * @param method The method to call on the client/client.
 * @param args Arguments to pass to the client/fontend.
 * @hidden
 */function _callOnClient(n){var e=[];for(var r=1;r<arguments.length;r++)e[r-1]=arguments[r];callOnHub.apply(void 0,t(["_invokeClient",n],e))}
/**
 * Starts a new `Transaction` and returns it. This is the entry point to manual tracing instrumentation.
 *
 * A tree structure can be built by adding child spans to the transaction, and child spans to other spans. To start a
 * new child span within the transaction or any span, call the respective `.startChild()` method.
 *
 * Every child span must be finished before the transaction is finished, otherwise the unfinished spans are discarded.
 *
 * The transaction must be finished with a call to its `.finish()` method, at which point the transaction with all its
 * finished child spans will be sent to Sentry.
 *
 * @param context Properties of the new `Transaction`.
 * @param customSamplingContext Information given to the transaction sampling function (along with context-dependent
 * default values). See {@link Options.tracesSampler}.
 *
 * @returns The transaction which was just started
 */function startTransaction(t,e){return callOnHub("startTransaction",n({},t),e)}export{_callOnClient,addBreadcrumb,captureEvent,captureException,captureMessage,configureScope,setContext,setExtra,setExtras,setTag,setTags,setUser,startTransaction,withScope};

