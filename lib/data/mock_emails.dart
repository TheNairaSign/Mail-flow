import '../../domain/entities/email_entity.dart';

final List<EmailEntity> mockEmails = [
  EmailEntity(
    id: '1',
    senderName: 'Alice Smith',
    senderEmail: 'alice.smith@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Project Update: Q2 Review',
    bodyPreview: 'Hi team, the Q2 review meeting is scheduled for next week...', 
    fullBody: '''Hi team,

The Q2 review meeting is scheduled for next week. Please come prepared with your team's progress reports. We will discuss the key achievements and challenges faced during the quarter.

Best regards,
Alice''',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '2',
    senderName: 'Bob Johnson',
    senderEmail: 'bob.j@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Meeting Reminder: Design Sync',
    bodyPreview: 'Just a friendly reminder about our design sync meeting today at 2 PM...', 
    fullBody: '''Hi,

Just a friendly reminder about our design sync meeting today at 2 PM in Conference Room B. We'll be reviewing the latest mockups for the new feature.

See you there,
Bob''',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '3',
    senderName: 'Charlie Brown',
    senderEmail: 'charlie.b@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Order #12345 Has Shipped!',
    bodyPreview: 'Great news! Your recent order from our store has been shipped...', 
    fullBody: '''Dear Customer,

Great news! Your recent order from our store, #12345, has been shipped and is on its way. You can track your package using the link below.

Thank you for your purchase!
Charlie Brown'''  ,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    isRead: false,
    isStarred: true,
  ),
  EmailEntity(
    id: '4',
    senderName: 'Diana Prince',
    senderEmail: 'diana.p@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Feedback Request: New Feature Prototype',
    bodyPreview: 'We\'d love to get your thoughts on the new feature prototype...', 
    fullBody: '''Hi team,

We'd love to get your thoughts on the new feature prototype. Please find the link to the prototype and a short survey attached. Your feedback is invaluable!

Thanks,
Diana''',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '5',
    senderName: 'Eve Adams',
    senderEmail: 'eve.a@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Important Security Alert for Your Account',
    bodyPreview: 'We detected unusual activity on your account. Please review immediately...', 
    fullBody: '''Dear User,

We detected unusual activity on your account. For your security, please review your recent login activity and change your password if you did not authorize this activity.

Sincerely,
Eve Adams (Security Team)''',
    timestamp: DateTime.now().subtract(const Duration(days: 3, minutes: 30)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '6',
    senderName: 'Frank White',
    senderEmail: 'frank.w@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Weekly Newsletter: Latest Tech Trends',
    bodyPreview: 'Check out our weekly newsletter covering the latest in AI and machine learning...', 
    fullBody: '''Hello,

Check out our weekly newsletter covering the latest in AI and machine learning. This week's edition features an exclusive interview with Dr. Anya Sharma.

Read more here!
Frank White''',
    timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '7',
    senderName: 'Grace Taylor',
    senderEmail: 'grace.t@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Invitation: Company Holiday Party',
    bodyPreview: 'You\'re invited to our annual company holiday party! RSVP by next Friday...', 
    fullBody: '''Hi team,

You're invited to our annual company holiday party! Join us for an evening of fun, food, and festivities. Please RSVP by next Friday so we can get a headcount.

Looking forward to celebrating with you,
Grace Taylor''',
    timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '8',
    senderName: 'Henry Green',
    senderEmail: 'henry.g@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Regarding Your Recent Support Ticket #9876',
    bodyPreview: 'We have received your support ticket and are actively working on a solution...', 
    fullBody: '''Dear Customer,

We have received your support ticket #9876 and are actively working on a solution. Our team will get back to you within 24 hours with an update.

Thank you for your patience,
Henry Green (Support Team)''',
    timestamp: DateTime.now().subtract(const Duration(days: 6, hours: 14)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '9',
    senderName: 'Ivy King',
    senderEmail: 'ivy.k@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Collaboration Opportunity: New Partnership',
    bodyPreview: 'We\'re excited to explore a potential collaboration with your organization...', 
    fullBody: '''Hello,

We're excited to explore a potential collaboration with your organization on an upcoming project. Please let us know your availability for a brief introductory call.

Sincerely,
Ivy King''',
    timestamp: DateTime.now().subtract(const Duration(days: 7, hours: 20)),
    isRead: false,
    isStarred: true,
  ),
  EmailEntity(
    id: '10',
    senderName: 'Jack Lee',
    senderEmail: 'jack.l@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Invoice #2024-001 for Services Rendered',
    bodyPreview: 'Please find attached your invoice for the services rendered last month...', 
    fullBody: '''Dear Client,

Please find attached your invoice #2024-001 for the services rendered last month. Payment is due within 30 days. Please contact us if you have any questions.

Thank you,
Jack Lee''',
    timestamp: DateTime.now().subtract(const Duration(days: 8, minutes: 5)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '11',
    senderName: 'Karen Hall',
    senderEmail: 'karen.h@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Subscription is Expiring Soon!',
    bodyPreview: 'Your premium subscription is set to expire on April 15th. Renew now to avoid interruption...', 
    fullBody: '''Dear User,

Your premium subscription is set to expire on April 15th. Renew now to avoid interruption of service and continue enjoying all premium features.

Best regards,
Karen Hall''',
    timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 3)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '12',
    senderName: 'Liam Scott',
    senderEmail: 'liam.s@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'New Policy Update: Privacy Terms',
    bodyPreview: 'We have updated our privacy policy. Please review the changes at your earliest convenience...', 
    fullBody: '''Dear Valued User,

We have updated our privacy policy to better protect your data. Please review the changes at your earliest convenience. Your continued use of our services implies acceptance of the new terms.

Sincerely,
Liam Scott''',
    timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 12)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '13',
    senderName: 'Mia Baker',
    senderEmail: 'mia.b@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Weekly Digest from TechNews',
    bodyPreview: 'Catch up on the week\'s biggest tech stories and analyses...', 
    fullBody: '''Hello,

Catch up on the week's biggest tech stories and analyses in your personalized weekly digest from TechNews. From AI breakthroughs to cybersecurity threats, we've got you covered.

Happy reading,
Mia Baker''',
    timestamp: DateTime.now().subtract(const Duration(days: 11, hours: 6)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '14',
    senderName: 'Noah Turner',
    senderEmail: 'noah.t@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Job Application Status: Software Engineer',
    bodyPreview: 'Thank you for your interest in the Software Engineer position. We have reviewed your application...', 
    fullBody: '''Dear Applicant,

Thank you for your interest in the Software Engineer position at our company. We have reviewed your application and will be in touch shortly regarding the next steps.

Sincerely,
Noah Turner (HR Department)''',
    timestamp: DateTime.now().subtract(const Duration(days: 12, hours: 18)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '15',
    senderName: 'Olivia Clark',
    senderEmail: 'olivia.c@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Reminder: Upcoming Webinar on Cloud Security',
    bodyPreview: 'Don\'t forget to join our free webinar on advanced cloud security strategies...', 
    fullBody: '''Hi,

Don't forget to join our free webinar on advanced cloud security strategies this Thursday at 10 AM PST. Register now to secure your spot!

See you there,
Olivia Clark''',
    timestamp: DateTime.now().subtract(const Duration(days: 13, minutes: 45)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '16',
    senderName: 'Peter Rodriguez',
    senderEmail: 'peter.r@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Monthly Statement is Ready',
    bodyPreview: 'Your monthly statement for March is now available in your account dashboard...', 
    fullBody: '''Dear Customer,

Your monthly statement for March is now available in your account dashboard. Log in to view your transactions and manage your account.

Thank you,
Peter Rodriguez''',
    timestamp: DateTime.now().subtract(const Duration(days: 14, hours: 2)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '17',
    senderName: 'Quinn Davis',
    senderEmail: 'quinn.d@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'New Feature Release: Enhanced Analytics',
    bodyPreview: 'We\'re excited to announce the release of our enhanced analytics dashboard...', 
    fullBody: '''Hi team,

We're excited to announce the release of our enhanced analytics dashboard! Get deeper insights into your data with new visualizations and reporting tools.

Learn more here,
Quinn Davis''',
    timestamp: DateTime.now().subtract(const Duration(days: 15, hours: 9)),
    isRead: false,
    isStarred: true,
  ),
  EmailEntity(
    id: '18',
    senderName: 'Rachel Evans',
    senderEmail: 'rachel.e@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Password Has Been Changed',
    bodyPreview: 'This is a confirmation that your password for your account has been successfully changed...', 
    fullBody: '''Dear User,

This is a confirmation that your password for your account has been successfully changed. If you did not make this change, please contact support immediately.

Sincerely,
Rachel Evans (Account Security)''',
    timestamp: DateTime.now().subtract(const Duration(days: 16, hours: 15)),
    isRead: true,
    isStarred: false,
  ),
  EmailEntity(
    id: '19',
    senderName: 'Sam Wilson',
    senderEmail: 'sam.w@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Holiday Sale: Up to 50% Off!',
    bodyPreview: 'Our annual holiday sale is here! Enjoy up to 50% off on selected items...', 
    fullBody: '''Hello,

Our annual holiday sale is here! Enjoy up to 50% off on selected items across our store. Don't miss out on these amazing deals!

Shop now,
Sam Wilson''',
    timestamp: DateTime.now().subtract(const Duration(days: 17, minutes: 20)),
    isRead: false,
    isStarred: false,
  ),
  EmailEntity(
    id: '20',
    senderName: 'Tina Miller',
    senderEmail: 'tina.m@example.com',
    recipientEmail: 'user@mail.com',
    subject: 'Your Feedback Matters: Take Our Survey',
    bodyPreview: 'We value your opinion! Please take a few minutes to complete our customer satisfaction survey...', 
    fullBody: '''Dear Customer,

We value your opinion! Please take a few minutes to complete our customer satisfaction survey and help us improve our services. Your feedback is important to us.

Thank you,
Tina Miller''',
    timestamp: DateTime.now().subtract(const Duration(days: 18, hours: 7)),
    isRead: true,
    isStarred: false,
  ),
];
