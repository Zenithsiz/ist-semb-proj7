#import "@preview/codly:1.2.0" as codly:
#import "util.typ" as util: code_figure, src_link


#set document(
	author: "Filipe Rodrigues",
	title: util.title,
	date: none
)
#set page(
	header: context {
		if counter(page).get().first() > 1 {
			image("images/tecnico-logo.png", height: 30pt)
		}
	},
	footer: context {
		if counter(page).get().first() > 1 {
			align(center, counter(page).display())
		}
	},
	margin: (x: 2cm, y: 30pt + 1.5cm)
)
#set text(
	font: "Libertinus Serif",
	lang: "en",
)
#set par(
	justify: true,
	leading: 0.65em,
)
#show link: underline

#show: codly.codly-init.with()

#include "cover.typ"
#pagebreak()

= Setup

For this setup, we simply connected the esp32 via usb and flashed the program to it, observing it's output through the terminal's output.

= Experiment

#let main_src = read("src/main/main.c")

== Experiment 1 vs Experiment 2

In experiment 1, we call `Task1`, followed by `Task2`. However, we aren't using any of `FreeRTOS`'s task creation functions, so once we call `Task1`, the current task executes 1, and since it never returns, `Task2` will never be execute.

== Test 1

For this test, we left both delays and priorities at their default:

- Task 1: Priority 5, Delay 1000
- Task 2: Priority 2, Delay 2000

After executing it, we saw the following output:

#raw(read("src/readings/1.txt"), block: true)

The newlines were added by us, one every second in this case.

As we can see, initially both tasks are execute immediately, then Task 1 executes every second, while Task 2 executes every 2 seconds.

When they execute at the same time, Task 1 is executed first since it has higher priority.

== Test 2

For this test, we kept the same delays, but modified the priorities as follows:

- Task 1: Priority 1, Delay 1000
- Task 2: Priority 5, Delay 2000

After executing it, we saw the following output:

#raw(read("src/readings/2.txt"), block: true)

Initially we see the same output, however whenever both tasks would be executed at the same time, we now see Task 2 being executed first, due to it having higher priority.

== Test 3

For this test, we kept the same priorities, but modified the delays as follows:

- Task 1: Priority 1, Delay 1000
- Task 2: Priority 5, Delay 1000

After executing it, we saw the following output:

#raw(read("src/readings/3.txt"), block: true)

As expected, both tasks are executed each second, and Task 2 goes first each time because it has higher priority.

We also tested the following delays:

- Task 1: Priority 1, Delay 2000
- Task 2: Priority 5, Delay 1000

After executing it, we saw the following output:

#raw(read("src/readings/4.txt"), block: true)

We see the same results as in test 1, but with the tasks reversed, with makes sense as we reversed everything.

== Test 4

For this task, we added a new task 3, that simulated a computational workload by sleeping with `ets_delay_us` for 2 seconds, as shown in @test4-code

#codly.codly(
	ranges: ((95, 100), (102, 102), (105, 105)),
	smart-skip: (first: false, last: false, rest: true),
)
#code_figure(
	raw(main_src, lang: "c", block: true),
	caption: [Test 4 code]
) <test4-code>

After executing it, we saw the following output:

#raw(read("src/readings/5.txt"), block: true)

We can see that although task 2 was successfully executed a few times, task 1 is never executed, because task 3 has higher priority, and never yields control back by sleeping.

We can also see an error show up that tells us our task has been running for a long time without yielding.

= Discussion Questions

== Why xTaskCreate is necessary in this case? Are the experiments equivalent?

No, `xTaskCreate` creates a new task, which is a similar construct to a thread, meaning we can run multiple tasks that never return on the same core.

On normal operating systems, threads are preemptive, meaning that they do not need to signal back to the operating system to be paused, and instead are preempted regularly without any notice. Another thread then runs on the same core until it's preempted too, and eventually that thread will run again.

However, on `FreeRTOS`, tasks must be cooperative, meaning that they must signal the operating system to be preempted, such as sleeping via `vTaskDelay`.

Whenever a task doesn't allow itself to be preempted for a long time, a watchdog is triggered that warns the user that a task has ran for a long time without yielding.

== How do priorities affect the execution order of tasks?

`FreeRTOS` uses a tick system, where each tick a task may be executed. If two tasks are scheduled to the same tick, the one with higher priority is executed first.

== What happens when tasks have equal priorities?

From our testing, whenever tasks with equal priorities are scheduled for the same tick, the one scheduled first is executed first.

== How does the delay configuration influence task scheduling?

As we saw on the experiments, changing the delay changes which tick the task will next be executed on.

== What are the implications of high-priority tasks with long execution times on system responsiveness?

Such tasks will not allow other lower priority tasks to be executed, as we saw on test 4, meaning the system will become unresponsive, potentially forever.

#bibliography("bibliography.yaml", style: "ieee", full: true)
