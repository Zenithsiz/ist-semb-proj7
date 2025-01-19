/*  Embedded Systems
    Lab Class 6 - MicroProject 7: Using FreeRTOS Tasks on ESP32
    Prof. Guilherme Paim
    IST (Instituto Superior Técnico), INESC-ID, Lisbon

    Link: https://onlinegdb.com/3eT2LMFTv
*/

/* Lab Experiment: Multitasking with FreeRTOS

   Let's experiment with FreeRTOS multitasking and enhance your understanding of real-time systems!

   1) Presentation: The students must present their MicroProjects to the professor in the free-time of the Lab class before the deadline.
   Group of Students: 1-2

   2) Report Format (by e-mail): ~ 3-5 pages in PDF
   Student Identification, Introduction, Experiment, Discussion, Conclusion
   Make sure that all questions are very well answered!
   Language: Portuguese/English

   3) Codes (by e-mail): The code must also be delivered in a Zip file.

   Documentation:
   https://docs.espressif.com/projects/esp-idf/en/v4.3/esp32/api-reference/system/freertos.html

   Objective:
   Learn how to implement multitasking on the ESP32 using FreeRTOS, create tasks with different priorities, and analyze their behavior in terms of scheduling and timing.

   Instructions:
   1. In the report, execute and compare both experiments, explaining the difference between them.
   On the experiment 2, execute this following tests:
   2. Test 1: Observe the output of the default program. Identify how Task1 and Task2 are executed based on their priorities and delay configurations.
   3. Test 2: Modify the priorities of the tasks in the `xTaskCreate` function. Set Task1 with lower priority (e.g., priority 1) and Task2 with higher priority (e.g., priority 5). Analyze how the behavior changes.
   4. Test 3: Change the delays (`vTaskDelay`) in each task. Experiment with equal delays, smaller delays for Task1, and larger delays for Task2. Observe the effect on task execution.
   5. Test 4: Create a third task (e.g., "Task3") that simulates a sensor reading or computational workload. Assign it a medium priority and delay. Analyze its interaction with Task1 and Task2.

   Discussion Questions:
   - Why xTaskCreate is necessary in this case ? Are the experiments equivalent ?
   - How do priorities affect the execution order of tasks?
   - What happens when tasks have equal priorities?
   - How does the delay configuration influence task scheduling?
   - What are the implications of high-priority tasks with long execution times on system responsiveness?
*/

//* Experiment 1 *//

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "rom/ets_sys.h"
#include <stdio.h>

/*
void Task1(void *params) {
	while (1) {
		printf("Reading temperature %s \n", (char *)params);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}

void Task2(void *params) {
	while (1) {
		printf("Reading humidity %s\n", (char *)params);
		vTaskDelay(2000 / portTICK_PERIOD_MS);
	}
}

void app_main(void) {
	Task1("Task 1");
	Task2("Task 2");
}
*/

//* End of Experiment 1 *//

//* Experiment 2 *//

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <stdio.h>

void Task1(void *params) {
	while (1) {
		printf("Reading temperature %s \n", (char *)params);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}

void Task2(void *params) {
	while (1) {
		printf("Reading humidity %s\n", (char *)params);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}

void Task3(void *params) {
	while (1) {
		printf("Reading sensor %s\n", (char *)params);
		ets_delay_us(2 * 1e6);
	}
}

void app_main(void) {
	xTaskCreate(&Task1, "Temperature reading", 2048, "Task 1", 1, NULL);
	xTaskCreate(&Task2, "Humidity reading", 2048, "Task 2", 5, NULL);
	xTaskCreate(&Task3, "Sensor reading", 2048, "Task 3", 2, NULL);
}

//* End of Experiment 2 *//
