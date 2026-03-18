'use strict'

const assert = require('assert')
const sleep = require('./')

let done = false

setTimeout(() => assert.strictEqual(done, false), 50)
sleep(100).then(() => { done = true })
setTimeout(() => assert.strictEqual(done, true), 150)
