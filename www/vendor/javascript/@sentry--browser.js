import{__assign as t}from"tslib";export{Severity}from"@sentry/types";import{Integrations as r,initAndBind as n,getCurrentHub as o}from"@sentry/core";export{Hub,SDK_VERSION,Scope,Session,addBreadcrumb,addGlobalEventProcessor,captureEvent,captureException,captureMessage,configureScope,getCurrentHub,getHubFromCarrier,makeMain,setContext,setExtra,setExtras,setTag,setTags,setUser,startTransaction,withScope}from"@sentry/core";import{T as s,D as u,B as c,a as f}from"../_/bc7a8917.js";export{B as BrowserClient,i as Transports}from"../_/bc7a8917.js";import{G as d,I as p,w as l}from"../_/97bba503.js";export{i as injectReportDialog}from"../_/97bba503.js";export{e as eventFromException,a as eventFromMessage}from"../_/72151e50.js";import{getGlobalObject as v,logger as g,resolvedSyncPromise as S,addInstrumentationHandler as m}from"@sentry/utils";import{Breadcrumbs as w}from"./integrations/breadcrumbs.js";import{LinkedErrors as E}from"./integrations/linkederrors.js";import{UserAgent as b}from"./integrations/useragent.js";var I=[new r.InboundFilters,new r.FunctionToString,new s,new w,new d,new E,new u,new b];function init(e){void 0===e&&(e={});void 0===e.defaultIntegrations&&(e.defaultIntegrations=I);if(void 0===e.release){var t=v();t.SENTRY_RELEASE&&t.SENTRY_RELEASE.id&&(e.release=t.SENTRY_RELEASE.id)}void 0===e.autoSessionTracking&&(e.autoSessionTracking=true);void 0===e.sendClientReports&&(e.sendClientReports=true);n(c,e);e.autoSessionTracking&&startSessionTracking()}
/**
 * Present the user with a report dialog.
 *
 * @param options Everything is optional, we try to fetch all info need from the global scope.
 */function showReportDialog(e){void 0===e&&(e={});var r=o();var n=r.getScope();n&&(e.user=t(t({},n.getUser()),e.user));e.eventId||(e.eventId=r.lastEventId());var s=r.getClient();s&&s.showReportDialog(e)}
/**
 * This is the getter for lastEventId.
 *
 * @returns The last event id of a captured event.
 */function lastEventId(){return o().lastEventId()}function forceLoad(){}function onLoad(e){e()}
/**
 * Call `flush()` on the current client, if there is one. See {@link Client.flush}.
 *
 * @param timeout Maximum time in ms the client should wait to flush its event queue. Omitting this parameter will cause
 * the client to wait until all events are sent before resolving the promise.
 * @returns A promise which resolves to `true` if the queue successfully drains before the timeout, or `false` if it
 * doesn't (or if there's no client defined).
 */function flush(e){var t=o().getClient();if(t)return t.flush(e);p&&g.warn("Cannot flush events. No client defined.");return S(false)}
/**
 * Call `close()` on the current client, if there is one. See {@link Client.close}.
 *
 * @param timeout Maximum time in ms the client should wait to flush its event queue before shutting down. Omitting this
 * parameter will cause the client to wait until all events are sent before disabling itself.
 * @returns A promise which resolves to `true` if the queue successfully drains before the timeout, or `false` if it
 * doesn't (or if there's no client defined).
 */function close(e){var t=o().getClient();if(t)return t.close(e);p&&g.warn("Cannot flush events and disable SDK. No client defined.");return S(false)}
/**
 * Wrap code within a try/catch block so the SDK is able to capture errors.
 *
 * @param fn A function to wrap.
 *
 * @returns The result of wrapped function call.
 */function wrap(e){return l(e)()}function startSessionOnHub(e){e.startSession({ignoreDuration:true});e.captureSession()}function startSessionTracking(){var e=v();var t=e.document;if("undefined"!==typeof t){var r=o();if(r.captureSession){startSessionOnHub(r);m("history",(function(e){var t=e.from,r=e.to;void 0===t||t===r||startSessionOnHub(o())}))}}else p&&g.warn("Session tracking in non-browser environment with @sentry/browser is not supported.")}var T="sentry.javascript.browser";var y={};var R=v();R.Sentry&&R.Sentry.Integrations&&(y=R.Sentry.Integrations);var h=t(t(t({},y),r),f);export{h as Integrations,T as SDK_NAME,close,I as defaultIntegrations,flush,forceLoad,init,lastEventId,onLoad,showReportDialog,wrap};

