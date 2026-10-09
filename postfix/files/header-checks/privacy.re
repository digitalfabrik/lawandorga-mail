# Drop sensible information from headers.
#  - Only such headers dropped that
#    - are not critical (e.g., "From."),
#    - may reveal information that the recipient does not know anyways.
#  - File written 2022-04-08, Debian bullseye, postfix debver 3.5.6-1+b1.
#    - Minor changes 2022-10-30.
#  - Idea from [0], further suggestions from [1, 2, 3, 4.1, 4.2, 5].


# Notes:
#  * We need to make sure that this does not come into conflict with DKIM
#    signatures.
#  * Below, headers differentiated on where we usually get them from.
#    - From Thunderbird, via submission.
#    - From sendmail(1), locally.
#  * This file is used by both
#    - ${smtp_header_checks},
#      - Applied to (smtp-)outbound mail, regardless of origin.
#        - Origin is either locally, or via (authenticated) submission, we do
#          not relay otherwise.
#    - ${submission_header_checks}.
#      - Applied to mail received via (authenticated) submission.
#      - This is needed additionally, to also apply this file to internal mail
#        (i.e., both sender and receiver are "at home" at this server).
#        - This does not apply to mail originating locally (e.g., via
#          sendmail(1)), but that should be okay.
#      * See master.cf on how this selective application is setup.
#        - See BUILTIN_FILTER_README; also [1, 4.2].



###########################################################
## Headers received from both Thunderbird and sendmail(1)

/^Received:/ IGNORE
#  - This usually contains the IP address, in particular.
#  - CONSIDER: REPLACE by a canonical header.
#    - Note the syntax in RFC 5322 (notably includes date).
#      - We'd need to extract that and insert with, e.g., ${1}.
#      - Note that the date includes TZ, which is PII.
#  - CONSIDER: Use STRIP instead.
#    - Problem: I cannot find no information on the would-be-injected "strip:"
#      "record" (header?).  It's not in the common RFC(s).



################################################################
## Headers received from Thunderbird, but not from sendmail(1)

/^User-Agent:/ IGNORE
#  - Gives information on MUA and OS.

#/^Mime-Version:/ IGNORE
#  - Suggested for removal by: [2]
#  - info: [10], RFC 2045
#  - This does not seem to contain PII.



####################################################################
## Headers received neither from Thunderbird, nor from sendmail(1)

/^X-Originating-IP:/ IGNORE
#  - Suggested for removal by: [2, 4.1, 5]
#  - info: [8]

/^X-Mailer:/ IGNORE
#  - Suggested for removal by: [2, 5]
#  - info: [9]

#/^X-Sender:/ IGNORE
#  - Suggested for removal by: [3]
#  - (little) information on X-Sender: [6, 7]
#  - I see no harm in this.



# References
#  * [0] https://wiki.archlinux.org/title/Postfix#Hide_the_sender's_IP_and_user_agent_in_the_Received_header
#  * [1] https://askubuntu.com/questions/78163/when-sending-email-with-postfix-how-can-i-hide-the-sender-s-ip-and-username-in#answer-78168
#  * [2] https://community.nethserver.org/t/remove-hide-client-sender-ip-from-postfix/15376/4
#  * [3] https://focus-linux.securityfocus.narkive.com/jeK17dy5/hide-internal-address-postfix#post2
#  * [4.1] https://serverfault.com/questions/413533/remove-hide-client-sender-ip-from-postfix#answer-413535
#  * [4.2] https://serverfault.com/questions/413533/remove-hide-client-sender-ip-from-postfix#answer-998993
#  * [5] https://major.io/2013/04/14/remove-sensitive-information-from-email-headers-with-postfix/
#  * [6] https://www.computerhope.com/issues/ch000918.htm
#  * [7] https://th-h.de/net/usenet/faqs/headerfaq/
#  * [8] https://en.wikipedia.org/wiki/X-Originating-IP
#  * [9] https://www.techwalla.com/articles/what-is-a-x-mailer-header
#  * [10] https://de.wikipedia.org/wiki/Multipurpose_Internet_Mail_Extensions#MIME_Part_1_%E2%80%93_Format_of_Internet_Message_Bodies
