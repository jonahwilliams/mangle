'use strict';

// Keep in sync with worker.js
const kPatchStartCode = 0;
const kPatchEndCode = 1;
const kElementOpenStartCode = 2;
const kElementOpenEndCode = 3;
const kAttributeCode = 4;
const kElementCloseCode = 5;
const kTextCode = 6;
const kIdentifyCode = 7;
const kListenCode = 8;

let index = 0;
let worker;
let nextId;
let messages;
const nodesById = new Map();
const idsByNode = new WeakMap();
const eventListeners = new Map();

function initWorker(script) {
    worker = new Worker(script);
    worker.onmessage = function(e) {
        handleMessages(e.data);
    }
}

function handleMessages(newMessages) {
    index = 0;
    nextId = null;
    messages = newMessages;
    for (; index < messages.length; index++) {
        const message = messages[index];
        switch (message.command) {
            case kPatchStartCode:
                const id = message.value;
                let patchRoot;
                if (id === 0) {
                    patchRoot = document.body;
                } else {
                    patchRoot = nodesById.get(id);
                }
                IncrementalDOM.patch(patchRoot, handlePatch);
                break;
            case kPatchEndCode:
                break;
        }
    }
}

function handlePatch() {
    for (; index < messages.length; index++) {
        const message = messages[index];
        switch (message.command) {
            case kPatchEndCode:
                nextId = null;
                return;
            case kElementOpenStartCode: {
                const name = message.name;
                IncrementalDOM.elementOpenStart(name);
                break;
            }
            case kElementOpenEndCode:
                IncrementalDOM.elementOpenEnd();
                break;
            case kAttributeCode: {
                const name = message.name;
                const value = message.value;
                IncrementalDOM.attr(name, value);
                break;
            }
            case kElementCloseCode: {
                const name = message.name;
                const el = IncrementalDOM.elementClose(name);
                if (nextId != null) {
                    nodesById.set(nextId, el);
                    idsByNode.set(el, nextId);
                    nextId = null;
                }
                break;
            }
            case kTextCode: {
                const value = message.value;
                IncrementalDOM.text(value);
                break
            }
            case kIdentifyCode: {
                const value = message.value;
                nextId = value;
                break;
            }
            case kListenCode: {
                const name = message.name;
                const value = message.value;
                IncrementalDOM.attr(name, createBoundListener(value));
                break;
            }
        }
    }
    nextId = null;
}

function createBoundListener(id) {
    return function() {
        worker.postMessage({
            id: id,
            data: null,
        });
    }
}