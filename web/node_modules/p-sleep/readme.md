# p-sleep

Promisified sleep function.

## Installation

```sh
npm install --save p-sleep
```

## Usage

```js
const sleep = require('p-sleep')

sleep(200).then(() => console.log('World!'))
sleep(100).then(() => console.log('Hello,'))
```

## API

### `sleep(ms: number) => Promise<void>`

Returns a `Promise` that resolves after `ms` milliseconds.
