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

let index = 0;
let worker;
let nextId;
let messages;
const patchRoots = new WeakMap();

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
                    patchRoot = patchRoots.get(id);
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
                    patchRoots.put(nextId, el);
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
        }
    }
    nextId = null;
}