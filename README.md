# Webim Client SDK Cordova Plugin

Cordova-friendly wrapper around Webim Client SDK 3.

Attention!!! This product is not ready for use yet. If you wish to use it, please contact us.

## Installation

`cordova create yourApp com.example.app YourApp` if project doesn't exist yet.

`git clone https://github.com/webim/webim-client-sdk-cordova-plugin.git`

`cd yourApp`

`cordova plugin add ../webim-client-sdk-cordova-plugin/`

`cordova platform add ios`

`cordova platform add android`


## Usage

* `init`

Initialisation webim session.

For beta-version initialisation demo webim session.

Account: demo.webim.ru

E-mail: o@webim.ru

Password: password

* `requestDialog`

Starts new chat or does nothing if chat was started before.

* `getMessagesHistory` with parameters `[limit, offset]`

`limit`: count of return messages.

`offset`: if offset == 0 method return last messages else next messages after previous messages.

* `typingMessage` with parameter `[message]`

Sends to server visitor typing message.

* `sendMessage` with parameter `[message]`

Sends to server visitor message.

* `sendFile` with parameter `[filePath]`

Sends to server visitor file.

* `onMessage`

Receives message.

* `onFile`

Receives file twice: sending file without URL and sent file with URL.

* `onTyping`

Receives operator typing event.

* `onConfirm`

Not implement yet.

* `onDialog`

Receives changed operator event.

* `onBan`

Receives visitor ban event.

* `close`

Destroys webim session.