/**
 * @title Mailbox
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract Mailbox {

  event Message(address indexed recipient, bytes message);

  /**
   * @notice Send message to account `recipient`.
   * @param to The address of the account to send the message to.
   * @param message The message in MIME type application/pkcs7-mime.
   */
  function send(address recipient, bytes message) {
    // Store the message in the transaction log.
    Message(recipient, message);
  }

}
