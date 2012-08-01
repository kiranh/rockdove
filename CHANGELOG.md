## v0.0.1

### initial release

* [Feature] Connects to EWS mailbox
* [Feature] Fetches the mail items
* [Feature] Parses each item (Signatures, Replies, Forward) 
* [Feature] Handles bounce types (Undeliverable,AutoReply)
* [Feature] Polls for every interval specified
* [Feature] Provides a template of the Daemon for easy plug & play

## v0.1.0

* [Enhancement] Ignore Delivery Failure Notices
* [Feature] Ignore Mails from specific email(s) list
* [Enhancement] Handles line breaks issue by setting text only mode for email body

## v0.2.0

*[Feature] Generated Yard documentation

## v0.3.0

*[Feature] Email Attachments & Save to File support 
*[Fix] Paste of links under email body generates unnecessary duplication of link tags
*[Fix] Sent Via signature parsing under email body screws up Reply & forwarded mails parsing 
*[Fix] Utf-8 encoding issues on email body & attachments