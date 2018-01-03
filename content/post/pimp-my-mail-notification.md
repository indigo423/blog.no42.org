---
title: "Pimp my Mail Notifications"
date: "2016-03-07"
categories:
    - "post"
tags:
    - "opennms"
    - "mail"
    - "notification"
cardheaderimage: "/images/default.jpg"
cardbackground: "#7cb342"
"author":
    name: "Ronny Trommer"
    description: "Writer of stuff"
    website: "https://blog.no42.org"
    email: "ronny@no42.org"
    twitter: "https://twitter.com/indigo423"
    github: "https://github.com/indigo423"
    image: "/images/avatar-64x64.png"
---

Notifications are important if you do monitoring.
I never liked mail notifications from monitoring systems where all the information is hidden in non-sense text.
Otherwise notifications never look the same, so I'm always forced to read all that useless crap again and again.
This is an approach to improve the usability of monitoring notifications using more a table pattern which helps me to recognize useful information much quicker.

Probably a lot of E-Mail guys will hate me for the reason I'm using HTML in mails.
The notifications work so much better for me so I don't care.
I've used just inline CSS and there is no JavaScript involved.
All the things are in the mail and there are no external resources loaded.
Here is how I work with OpenNMS mail notifications.

<figure>
    <a href="https://photos.google.com/share/AF1QipOF0X2WnZsQpuyfbzlUcRJKElFBg4JG9X8PtGNNmpJ9T_gE9YRw912ZH7VT7lo-wQ/photo/AF1QipPLxX1Fi7tc7KpYSgIXVZ-LrM_Vb3dJ--tcpDc9?key=U0JyNEtXb1hZcEJaRVdYN2I1SDlfc3IwSkI0djJn" target="_BLANK"><img src="https://lh3.googleusercontent.com/BIsj5SfMAEgQ_HCFmww3GblrPArQC5ov7csUrEbmsUDSSW0fD19eR32oMDO1ksvgWXDTJ6nn8SQDcLFu3LeoO9nMCCB96VXh9ocfu6iuxgGAd1nPEXh2McSaDK7AoysakkmTgAZ36dDf8uieIYWCPBytneUNFqbmch5Ze-SJgacRHqDMJ5zMj4we8zp6EjtyYcQCt8qWqJTHnKo4BslioRNTtBBUFuENC_Inw5eNehdypmVz4soZ8uUGr_ebcr427lBrACLf-ZqxdPp726Jy3Y2ZRNTfwbarNac8Zlr1zmTGOSgz74DIwmTYS7J2YzEwpYR6zstlkgH5EOYGKdo2lP3QDFb4ccUbvY4HrZbiCF30awqF9eszcn_uiyK3mlHoabZwLot4knHobLemodhAL9cj5_yHaVwDkkU5OVzLHJFZhHSCBV9c1kSUxeuUJ_tg86PCrPRe2mQF8N1IzyaommrRCO-y6kDCqjRSEfWi0Z-mBfcCfkydFuKzXjVMbBZ5nHWq7dt-xhhVQjSF_0IBeNYLRoxgOL0zFmqmD_0d2jZAr34KgOP4QWPKBVj4T2vYp_9C=w522-h356-no" alt="Mailbox with OpenNMS notifications" /></a>
    <figcaption>My Mailbox with OpenNMS notifications.</figcaption>
</figure>

I use a tagged subject line <1> to get notifications filtered.
The severity variable in OpenNMS notification is used to assign a color.

To get quickly to the source of the problem, I created the object information as a link <2>.
In this case it gets me to the resoure graphs of the node which had the high threshold exceeded notification.

I've created a inline CSS style named after OpenNMS severities so the status color <3> is correct assigned based on the severity of the event which triggered the notification.
Additionally the measured value which exceeded the threshold is red colored <4> and added also some context information how the threshold is configured.

The links to the notification and event details jump to the correct places in OpenNMS <5>.

To give some more context what kind of node has a problem, I've added some asset information which are imported form the OpenNMS Provisioning system.
I can see what operating system is installed, product number, serial number and where it is located.

I ran into an issue regarding the RESOLVED prefix for resolved notifications.
The prefix is added not just to the subject, also added as the first line of the original notification.
Probably there is some code change necessary to get this thing sorted.

If you like mail notifications and you want to give it a try, I've dropped my configuration in a <a href="https://github.com/opennms-forge/opennms-notification-templates" target="_BLANK">GitHub repository</a>.
The notifications look also nice on my phone and happy to add some monitoring love to OpenNMS.

Feel free to fork, improve and share.
