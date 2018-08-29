'use strict';

// Keep in sync with client.js
const kPatchStartCode = 0;
const kPatchEndCode = 1;
const kElementOpenStartCode = 2;
const kElementOpenEndCode = 3;
const kAttributeCode = 4;
const kElementCloseCode = 5;
const kTextCode = 6;
const kIdentifyCode = 7;
const kListenCode = 8;

let messages = [];
let eventDispatcher;

onmessage = function(event) {
    const id = event.data.id;
    const data = event.data.data;
    if (eventDispatcher != null) {
        eventDispatcher(id, data);
    }
}

function setEventDispatcher(dispatcher) {
    eventDispatcher = dispatcher;
}

function elementOpenStart(name) {
    messages.push({
        command: kElementOpenStartCode,
        name: name,
    });
}

function elementOpenEnd(name) {
    messages.push({
        command: kElementOpenEndCode,
        name: name,
    });
}

function attribute(name, value) {
    messages.push({
        command: kAttributeCode,
        name: name,
        value: value,
    });
}

function listen(name, value) {
    messages.push({
        command: kListenCode,
        name: name,
        value: value,
    })
}

function identify(id) {
    messages.push({
        command: kIdentifyCode,
        value: id,
    });
}

function elementClose(name) {
    messages.push({
        command: kElementCloseCode,
        name: name,
    });
}

function text(value) {
    messages.push({
        command: kTextCode,
        value: value,
    });
}

function patchStart(id) {
    messages.push({
        command: kPatchStartCode, value: id
    });
}

function patchEnd() {
    messages.push({
        command: kPatchEndCode,
    })
}

function flushMessages() {
    postMessage(messages);
    messages = [];
}
