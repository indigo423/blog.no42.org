---
title: "RRDtool graph improvement"
description: "Improve RRDTool graph rendering in OpenNMS"
date: "2014-03-18"
categories:
    - "post"
tags:
    - "opennms"
    - "rrdtool"
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

If you have [OpenNMS](http://www.opennms.org/) with [RRDtool](http://www.rrdtool.org/) running, you can improve the whole rendering a little bit just by replacing the `command.prefix` in the following files:

* `snmp-graph.properties`
* `snmp-adhoc-graph.properties`
* `response-graph.properties`
* `response-adhoc-graph.properties`

~~~bash
command.prefix=/usr/bin/rrdtool graph - --imgformat PNG --font DEFAULT:7 --font TITLE:10 --start {startTime} --end {endTime} -E --width=1000 --height=180
~~~

I don’t like the stamp size graphs in OpenNMS, so I changed it for all.
It could be problematic if you have grouped graph report (KSC report).
So if you have trouble, you can just remove the –width and –height parameter.
The command will also overwrite the width and height for all graphs, so they have all the same size.
You have to be careful if you have KSC reports with multiple columns.
If you have RRDtool running, you can improve the graphs with anti-aliasing using a few additional parameters:

~~~bash
command.prefix=/usr/bin/rrdtool graph - --imgformat PNG -R normal --font-render-mode normal -l 0 -E --font DEFAULT:7 --font TITLE:10 --start {startTime} --end {endTime} -c ARROW#5e5e5e --width=1000 --height=180
~~~

<figure>
    <img src="https://lh3.googleusercontent.com/0LOuoKMG9uJ_xBJnpL4rWhMVzHJ4EXm0WWs35TWYXdxbFJFFkp61Ope0mZLOfgPcnTNUIwT3IgdO5tM-Y76-h1A_0s73bGhp5GZsAtuT2sNmK_VlyteCjvuxaaqrNj8YUTl8yFcxn_b3XkEmp7s2HBngyOXeGs_Oqg7AfcGHWo7JmHBDBBSFnwrdyBPKi3JU4KeGIhfy_wqtH2VX7SoZPt94fI6Qj3q72ARxgYVifiooZvfEmhL7yyhbZyjWsHXCH2FH5Ay-VVUUI3o5GzKUEWYW19isaedr3d96KzeCu0YIFbEsYeYCBhxmKyKDizgmCXONLyvYVO4Ma9BRXI4yRNtDbHZ48h4mUVpFOQluNJMfWZy-Uvb2_5z7Ga3tQ127Q72MX4ILmlaxPfvbVLtkdS3ganw5SPfjur37ILY36O0nszLlqCE3WvugoUHIPjGA1Qal4PjVbiIuqSoKhY7fnrfq-WociWpZuew6nPy-cgsRogn7a7EmnWbB6QbHGyES3dPqqdTd-bolKJJSm4DZETnqAV4AK2SCZRBpmA30HqSwjVrmaETySJgAEbuMamy5UE3i=w1040-h733-no" />
    <figcaption>Default graph without anti-aliasing.</figcaption>
</figure>

<figure>
    <img src="https://lh3.googleusercontent.com/Sc9zYSQA35M90gIVx96HlBgKmbknlw6DBQbZh9vyaHHDuFGCqrwm_mUKBZ7b9f_PLx0N_nTCVCDnQ-qw6UxTgEZ1kX7fjMHvhHi7Dsb8SIDvMUDIirJAMoTFqZ0jLHqObIsHgQXp5zVyeq4RxYiA8mK2ONr5STJb0Vi6iqB7sNaSk5tfoMe6lddjkpwSMDtdBM88oow8G0HignDe2Pb-9MWa_vC2h1OGL2Elc1hKoFrlDRed_h_DgOhTg78AuREw7_KaV3FU8bX5h4fPc_pyqGkaUJCEx0vUe_a6j_X4N9mWXuA2uoQ37w82XdG1KqeEstYWusUNFmNKRWUu3YG3aO1ni5ayo24SdHaE6ZeNR2m_LWbvHSABnA9DJJcJWufzEqGzvnrTCtcMXTWWZlhQ96D5PrRr8uxPdoOmtblNua_8cLdYu3TrJg18tZyGaKIyF3pUzaudZIzKfU178k7G1avbw33tCbcaRvJ6hvwWCVcaGTbWiSrYxDLu2JVGKEJT4w1wNj-zbTvPqmQ_M-j8aaEn8fSLMqZJU7i0GjoefeHqO3l_OXgLL2oFAkxddM0A0oRo=w1039-h780-no" />
    <figcaption>Default graph with anti-aliasing.</figcaption>
</figure>
