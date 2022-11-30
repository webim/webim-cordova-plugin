<h1>Webim Cordova Plugin</h1>

Webim Cordova Plugin is the free software for integrating Webim chat functionality into mobile apps developed using the Apache Cordova framework.

<h2>Table of contents</h2>
<a href="#installation">Setting up</a>


<a href="#methods">Methods</a>
<p style="padding-left: 30px;"><a href="#init">method init</a></p>
<p style="padding-left: 30px;"><a href="#request-dialog">method requestDialog</a></p>
<p style="padding-left: 30px;"><a href="#get-messages-history">method  getMessagesHistory</a></p>
<p style="padding-left: 30px;"><a href="#typing-message">method typingMessage</a></p>
<p style="padding-left: 30px;"><a href="#send-message">method sendMessage</a></p>
<p style="padding-left: 30px;"><a href="#reply-message">method replyMessage</a></p>
<p style="padding-left: 30px;"><a href="#send-file">method sendFile</a></p>
<p style="padding-left: 30px;"><a href="#send-keyboard-request">method sendKeyboardRequest</a></p>
<p style="padding-left: 30px;"><a href="#send-survey-answer">method sendSurveyAnswer</a></p>
<p style="padding-left: 30px;"><a href="#cancel-survey">method cancelSurvey</a></p>
<p style="padding-left: 30px;"><a href="#on-message">method onMessage</a></p>
<p style="padding-left: 30px;"><a href="#on-deleted-message">method onDeletedMessage</a></p>
<p style="padding-left: 30px;"><a href="#on-file">method onFile</a></p>
<p style="padding-left: 30px;"><a href="#on-typing">method onTyping</a></p>
<p style="padding-left: 30px;"><a href="#on-confirm">method onConfirm</a></p>
<p style="padding-left: 30px;"><a href="#on-dialog">method onDialog</a></p>
<p style="padding-left: 30px;"><a href="#on-ban">method onBan</a></p>
<p style="padding-left: 30px;"><a href="#on-survey">method onSurvey</a></p>
<p style="padding-left: 30px;"><a href="#on-next-question">method onNextQuestion</a></p>
<p style="padding-left: 30px;"><a href="#on-survey-cancel">method onSurveyCancel</a></p>
<p style="padding-left: 30px;"><a href="#on-chat-state">method onChatState</a></p>
<p style="padding-left: 30px;"><a href="#rateOperator">method rateOperator</a></p>
<p style="padding-left: 30px;"><a href="#rateOperatorWithNote">method rateOperatorWithNote</a></p>
<p style="padding-left: 30px;"><a href="#showRateOperatorWindow">method showRateOperatorWindow</a></p>
<p style="padding-left: 30px;"><a href="#sendDialogToEmailAddress">method sendDialogToEmailAddress</a></p>
<p style="padding-left: 30px;"><a href="#on-unread-by-visitor-message-count">method onUnreadByVisitorMessageCount</a></p>
<p style="padding-left: 30px;"><a href="#get-unread-by-visitor-message-count">method getUnreadByVisitorMessageCount</a></p>
<p style="padding-left: 30px;"><a href="#set-chat-read">method setChatRead</a></p>
<p style="padding-left: 30px;"><a href="#get-show-email-button">method getShowEmailButton</a></p>
<p style="padding-left: 30px;"><a href="#on-logging">method onLogging</a></p>
<p style="padding-left: 30px;"><a href="#close">method close</a></p>

<a href="#objects">Objects</a>
<p style="padding-left: 30px;"><a href="#message">Message</a></p>
<p style="padding-left: 30px;"><a href="#dialog-state">DialogState</a></p>
<p style="padding-left: 30px;"><a href="#employee">Employee</a></p>
<p style="padding-left: 30px;"><a href="#survey">Survey</a></p>
<p style="padding-left: 30px;"><a href="#survey-config">SurveyConfig</a></p>
<p style="padding-left: 30px;"><a href="#survey-current-question-info">SurveyCurrentQuestionInfo</a></p>
<p style="padding-left: 30px;"><a href="#survey-question">SurveyQuestion</a></p>
<p style="padding-left: 30px;"><a href="#keyboard">Keyboard</a></p>
<p style="padding-left: 30px;"><a href="#keyboard-button">KeyboardButton</a></p>
<p style="padding-left: 30px;"><a href="#keyboard-request">KeyboardRequest</a></p>
<p style="padding-left: 30px;"><a href="#keyboard-response">KeyboardResponse</a></p>

<h2 id="installation"><b>Setting up</b></h2>

The plugin can be installed from git repository.

Example: `cordova plugin add https://github.com/webim/webim-cordova-plugin.git`

<h2 id="methods"><b>Methods</b></h2>
<p style="padding-left: 30px;">For further reference about development of plugins for Apache Cordova, please consult <a href="https://cordova.apache.org/docs/en/latest/guide/hybrid/plugins/index.html">the official Plugin Development Guide </a>.</p>

<h4 id="init" style="padding-left: 30px;"><b>method webimsdk.init(param, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;"><em>Webim</em> session initialization. Another plugin methods don't work without session initialization. </p>
<p style="padding-left: 60px;">Parameter <em>param</em> is JSON with:</p>
<p style="padding-left: 90px;"><em>accountName</em> field — <em>Webim</em> service account name. Specify either full server base URL (e. g., "https://demo.webim.ru") or just account slug (e. g., "demo"). Type — <em>String</em>.</p>
<p style="padding-left: 90px;"><em>location</em> field — <em>String</em>-typed location name. Usually default available location names are "mobile" and "default". To create any other one you can contact service support. Field is mandatory.</p>
<p style="padding-left: 90px;"><em>pushToken</em> field — <em>String</em>-typed push token for push notification receiving.</p>
<p style="padding-left: 90px;"><em>visitorFields</em> field — visitor authorization data. Without this method calling a visitor is anonymous, with randomly generated ID. This ID is saved inside app UserDefaults and can be lost (e.g. when app is uninstalled), thereby message history is lost too. Authorized visitor data are saved by server and available with any device. More information on <a href="https://webim.ru/kb/dev/identification/"><em>Webim</em> web site</a>. Type — <em>JSON</em>. Field is mandatory.</p>
<p style="padding-left: 90px;"><em>storeHistoryLocally</em> field. By default session doesn't save message history inside SQLite DB file. To activate this functionality you can use this method with true value. Type — <em>Boolean</em>.</p>
<p style="padding-left: 90px;"><em>closeWithClearVisitorData</em> field. If this parameter is true, session will close with deleting visitor data. Type — <em>Boolean</em>.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="request-dialog" style="padding-left: 30px;"><b>method webimsdk.requestDialog(</b><b>successCallback, errorCallback</b><b>)</b></h4>
<p style="padding-left: 60px;">Start chat. When a user sends a message, the chat begins automatically, so calling the method is optional.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="get-messages-history" style="padding-left: 30px;"><b>method webimsdk.getMessagesHistory(limit, offset, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Requests the messages above in history. </p>
<p style="padding-left: 60px;"><em>limit</em> parameter — method returns not more than <em>limit</em> of messages. Type — <em>Int</em>.</p>
<p style="padding-left: 60px;"><em>offset</em> parameter — histrory offset. Type — <em>Int</em>,  0 value means last message in history, another value returns next messages after previous method running.</p>
<p style="padding-left: 60px;">Function <em> successCallback(messages)</em> is executed when the method is successfully completed. <em>messages</em> parameter contains messages array. See <a href="#message"><em>Message</em></a></p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="typing-message" style="padding-left: 30px;"><b>method webimsdk.typingMessage(message, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter.</p>
<p style="padding-left: 60px;">When there's multiple calls of this method occurred, draft message is sending to service one time per second.</p>
<p style="padding-left: 60px;"><em>message</em> parameter — draft message Type — <em>String</em>. When empty string value passed it means that visitor stopped to type a message or deleted it.</p>
<p style="padding-left: 60px;">Function <em> successCallback(text)</em> is executed when the method is successfully completed. <em>text</em> parameter contains draft message.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="send-message" style="padding-left: 30px;"><b>method webimsdk.sendMessage(message, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Send message.</p>
<p style="padding-left: 60px;"><em>message</em> parameter — sending message. Type — <em>String</em>. Max message length — 32000 symbols.
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter contains message, type — <a href="#message"><em>Message</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="reply-message" style="padding-left: 30px;"><b>method webimsdk.replyMessage(message, repliedMessage, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Reply message. Message can be replied if its parameter <em>canBeReplied</em> is true.</p>
<p style="padding-left: 60px;"><em>message</em> parameter — sending message. Type — <em>String</em>. Max message length — 32000 symbols.
<p style="padding-left: 60px;"><em>repliedMessage</em> parameter — replied message. Type — <em>Message</em>. JSON with message parameters.
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter contains message, type — <a href="#message"><em>Message</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="send-file" style="padding-left: 30px;"><b>method webimsdk.sendFile(filePath, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Sends a file message.</p>
<p style="padding-left: 60px;"><em>filePath</em> parameter — file path.</p>
<p style="padding-left: 60px;">Function <em> successCallback(id)</em> is executed when the method is successfully completed. <em>id</em> parameter contains file message <em>ID</em>, type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="send-keyboard-request" style="padding-left: 30px;"><b>method webimsdk.sendKeyboardRequest(requestMessageCurrentChatId, buttonId, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Sends a file keyboard request.</p>
<p style="padding-left: 60px;"><em>requestMessageCurrentChatId</em> parameter — message current chat id.</p>
<p style="padding-left: 60px;"><em>buttonID</em> parameter — selected button id.</p>
<p style="padding-left: 60px;">Function <em> successCallback(id)</em> is executed when the method is successfully completed. <em>id</em> parameter contains file message <em>ID</em>, type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="send-survey-answer" style="padding-left: 30px;"><b>method webimsdk.sendSurveyAnswer(surveyAnswer, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Sends a answer to current question.</p>
<p style="padding-left: 60px;"><em>surveyAnswer</em> parameter — survey answer.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="cancel-survey" style="padding-left: 30px;"><b>method webimsdk.surveyCancel(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Close the survey.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="on-message" style="padding-left: 30px;"><b>method webimsdk.onMessage(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when added a new operator message, a new system message or sending visitor message.</p>
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter contains message, type — <a href="#message"><em>Message</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-deleted-message" style="padding-left: 30px;"><b>method webimsdk.onDeletedMessage(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when deleted a message.</p>
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter contains message, type — <a href="#message"><em>Message</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-file" style="padding-left: 30px;"><b>method webimsdk.onFile(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when added a new file message.</p>
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter contains message, type — <a href="#message"><em>Message</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-typing" style="padding-left: 30px;"><b>method webimsdk.onTyping(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when operator types message.</p>
<p style="padding-left: 60px;">Function <em> successCallback(message)</em> is executed when the method is successfully completed. <em>message</em> parameter always contains empty string.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-confirm" style="padding-left: 30px;"><b>method webimsdk.onConfirm(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when visitor message received by the server.</p>
<p style="padding-left: 60px;">Function <em> successCallback(id)</em> is executed when the method is successfully completed. <em>id</em> parameter contains file message <em>ID</em>, type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-dialog" style="padding-left: 30px;"><b>method webimsdk.onDialog(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when operator changed in the chat.</p>
<p style="padding-left: 60px;">Function <em> successCallback(dialogState)</em> is executed when the method is successfully completed. <em>dialogState</em> parameter contains new dialog state, type — <a href="#dialog-state"><em>DialogState</em></a>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-ban" style="padding-left: 30px;"><b>method webimsdk.onBan(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when the visitor is baned.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-survey" style="padding-left: 30px;"><b>method webimsdk.onSurvey(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when the visitor can answer to survey.</p>
<p style="padding-left: 60px;">Function <em> successCallback(survey)</em> is executed when the method is successfully completed. <em>survey</em> parameter contains <em>Survey</em> object.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-next-question" style="padding-left: 30px;"><b>method webimsdk.onNextQuestion(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when the visitor can answer to this question.</p>
<p style="padding-left: 60px;">Function <em> successCallback(surveyQuestion)</em> is executed when the method is successfully completed. <em>surveyQuestion</em> parameter contains <em>SurveyQuestion</em> object.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-survey-cancel" style="padding-left: 30px;"><b>method webimsdk.onSurveyCancel(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when the survey is canceled.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="on-chat-state" style="padding-left: 30px;"><b>method webimsdk.onChatState(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when chat state was changed.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>chatState</em> field with chat state name: unknown, none, queue, chatting, chattingWithRobot, deleted, routing, invitation, closedByVisitor or closedByOperator.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="rateOperator" style="padding-left: 30px;"><b>method webimsdk.rateOperator(id, rating, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Rates an operator.</p>
<p style="padding-left: 60px;"><em>id</em> parameter — operator id. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>rating</em> parameter — a number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server. Type — <em>Int</em>.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="rateOperatorWithNote" style="padding-left: 30px;"><b>method webimsdk.rateOperatorWithNote(id, rating, note, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Rates an operator.</p>
<p style="padding-left: 60px;"><em>id</em> parameter — operator id. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>rating</em> parameter — a number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server. Type — <em>Int</em>.</p>
<p style="padding-left: 60px;"><em>note</em> parameter — some commentary. Type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="showRateOperatorWindow" style="padding-left: 30px;"><b>method webimsdk.showRateOperatorWindow(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when the visitor should rate an operator at the end of chat.</p>
<p style="padding-left: 60px;">Function <em> successCallback()</em> is executed when the method is successfully completed.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="sendDialogToEmailAddress" style="padding-left: 30px;"><b>method webimsdk.sendDialogToEmailAddress(emailAddress, successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Rates an operator.</p>
<p style="padding-left: 60px;"><em>emailAddress</em> parameter — send dialog to this email address. Type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="on-unread-by-visitor-message-count" style="padding-left: 30px;"><b>method webimsdk.onUnreadByVisitorMessage(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when operator send new message.</p>
<p style="padding-left: 60px;">Function <em> successCallback(unreadByVisitorMessageCount)</em> is executed when value of unread by visitor message count changed. <em>unreadByVisitorMessageCount</em> parameter contains unread by visitor message count, type — <em>Int</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="get-unread-by-visitor-message-count" style="padding-left: 30px;"><b>method webimsdk.getUnreadByVisitorMessage(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback returns unread by visitor message count.</p>
<p style="padding-left: 60px;">Function <em> successCallback(unreadByVisitorMessageCount)</em> returns value of unread by visitor message count. <em>unreadByVisitorMessageCount</em> parameter contains unread by visitor message count, type — <em>Int</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="set-chat-read" style="padding-left: 30px;"><b>method webimsdk.setChatRead(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">All messages will be read by visitor.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="get-show-email-button" style="padding-left: 30px;"><b>method webimsdk.getShowEmailButton(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Method returns true if app should show send chat to email button.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>showEmailButton</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h4 id="on-logging" style="padding-left: 30px;"><b>method webimsdk.onLogging(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Success callback called when new log entry appears.</p>
<p style="padding-left: 60px;">Function <em> successCallback(log)</em> returns new log entry appears. <em>log</em> parameter contains new log entry, type — <em>String</em>.</p>
<p style="padding-left: 60px;">Function <em> errorCallback()</em> will never be executed.</p>

<h4 id="close" style="padding-left: 30px;"><b>method webimsdk.close(successCallback, errorCallback)</b></h4>
<p style="padding-left: 60px;">Close session and stop session network activity.</p>
<p style="padding-left: 60px;">Function <em> successCallback(jsonString)</em> is executed when the method is successfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>
<p style="padding-left: 60px;">Function <em> errorCallback(jsonString)</em> is executed when the method is unsuccessfully completed. <em>jsonString</em> parameter contains <em>result</em> field with execution method completion information.</p>

<h2 id="objects"><b>Objects</b></h2>
<h4 id="message" style="padding-left: 30px;"><b>Message</b></h4>
<p style="padding-left: 60px;">Message information.</p>
<p style="padding-left: 60px;"><em>id</em> field— message <em>ID</em>. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>text</em> field — message text. Type — <em>String.</em></p>
<p style="padding-left: 60px;"><em>url</em> field — file <em>URL</em>. No field if message isn't file message. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>timestamp</em> field — sending time in ms. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>sender</em> field — message sender name. No field if message is system message. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>operator</em> field — operator information. No field if message isn't operator message. Type — <em>Employee.</em></p>
<p style="padding-left: 60px;"><em>keyboard</em> field — keyboard information. Type — <em>Keyboard.</em></p>
<p style="padding-left: 60px;"><em>isFirst</em> field — true if message is the first message in current chat. Type — <em>Boolean.</em></p>
<p style="padding-left: 60px;"><em>isReadByOperator</em> field — true if message is read by operator. Type — <em>Boolean.</em></p>
<p style="padding-left: 60px;"><em>canBeReplied</em> field — true if message is can be replied. Type — <em>Boolean.</em></p>
<p style="padding-left: 60px;"><em>quote</em> field — quote information. Type — <em>Quote.</em></p>


<h4 id="dialog-state" style="padding-left: 30px;"><b>DialogState</b></h4>
<p style="padding-left: 60px;">Dialog state info. See method <em><a href="#on-dialog">onDialog</a>.</em></p>
<p style="padding-left: 60px;"><em>employee</em> field — new operator in current chat. Type — <em>Employee</em>.</p>

<h4 id="employee" style="padding-left: 30px;"><b>Employee</b></h4>
<p style="padding-left: 60px;">Operator information.</p>
<p style="padding-left: 60px;"><em>id</em> field — operator <em>ID</em>. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>firstname</em> field — operator first name. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>avatar</em> field — operator avatar <em>URL</em>. Type — <em>String</em>.</p>

<h4 id="survey" style="padding-left: 30px;"><b>Survey</b></h4>
<p style="padding-left: 60px;">Survey information.</p>
<p style="padding-left: 60px;"><em>id</em> field — survey <em>ID</em>. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>config</em> field — survey config. Type — <em>SurveyConfig</em>.</p>
<p style="padding-left: 60px;"><em>currentQuestionInfo</em> field — information about current question in survey <em>URL</em>. Type — <em>SurveyCurrentQuestionInfo</em>.</p>

<h4 id="survey-config" style="padding-left: 30px;"><b>SurveyConfig</b></h4>
<p style="padding-left: 60px;">Survey config information.</p>
<p style="padding-left: 60px;"><em>id</em> field — survey config <em>ID</em>. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>version</em> field — survey config version. Type — <em>String</em>.</p>

<h4 id="survey-current-question-info" style="padding-left: 30px;"><b>SurveyCurrentQuestionInfo</b></h4>
<p style="padding-left: 60px;">Survey current question information.</p>
<p style="padding-left: 60px;"><em>formId</em> field — survey current question form <em>ID</em>. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>questionId</em> field — survey current question <em>ID</em>. Type — <em>String</em>.</p>

<h4 id="survey-question" style="padding-left: 30px;"><b>SurveyQuestion</b></h4>
<p style="padding-left: 60px;">Survey question information.</p>
<p style="padding-left: 60px;"><em>type</em> field — survey question type. Type can be "stars", "radio", "comment". Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>text</em> field — survey question text. Type — <em>String</em>.</p>

<h4 id="keyboard" style="padding-left: 30px;"><b>Keyboard</b></h4>
<p style="padding-left: 60px;">Keyboard information.</p>
<p style="padding-left: 60px;"><em>state</em> field — keyboard state. Type can be "pending" (all buttons aren't selected), "completed" (keyboard has selected button), "canceled" (keyboard is canceled without selected button). Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>buttons</em> field contains buttons array. See <a href="#keyboard-button"><em>KeyboardButton</em></a>.</p>
<p style="padding-left: 60px;"><em>keyboardResponse</em> field contains information about selected button. Type — <em>KeyboardResponse</em>.</p>

<h4 id="keyboard-button" style="padding-left: 30px;"><b>KeyboardButton</b></h4>
<p style="padding-left: 60px;">Keyboard button information.</p>
<p style="padding-left: 60px;"><em>text</em> field — text on button. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>id</em> field — button id. Type — <em>String</em>.</p>

<h4 id="keyboard-request" style="padding-left: 30px;"><b>KeyboardRequest</b></h4>
<p style="padding-left: 60px;">Keyboard request information.</p>
<p style="padding-left: 60px;"><em>messageID</em> field — id of message with keyboard. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>button</em> field — selected button. Type — <a href="#keyboard-button"><em>KeyboardButton</em></a>.</p>

<h4 id="keyboard-request" style="padding-left: 30px;"><b>KeyboardRequest</b></h4>
<p style="padding-left: 60px;">Keyboard request information.</p>
<p style="padding-left: 60px;"><em>buttonID</em> field — selected button id. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>messageID</em> field — id of message with keyboard. Type — <em>String</em>.</p>

<h4 id="quote" style="padding-left: 30px;"><b>Quote</b></h4>
<p style="padding-left: 60px;">Quote information.</p>
<p style="padding-left: 60px;"><em>state</em> field — quote state. Type — <em>String</em>. Can be <em>filled</em>, <em>pending</em> and <em>notFound</em>.</p>
<p style="padding-left: 60px;"><em>senderName</em> field — name of message author. No field if message isn't operator message. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>text</em> field — quote text. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>timestamp</em> field — sending time in ms. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>authorID</em> field — author id. No field if message isn't operator message. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>id</em> field — replied message id. Type — <em>String</em>.</p>
<p style="padding-left: 60px;"><em>url</em> field — file <em>URL</em>. No field if replied message isn't file message. Type — <em>String</em>.</p>