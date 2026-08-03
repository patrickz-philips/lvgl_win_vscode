/**
 * @file main.c
 *
 */

/*********************
 *      INCLUDES
 *********************/

#ifndef _DEFAULT_SOURCE
  #define _DEFAULT_SOURCE /* needed for usleep() */
#endif

#include <stdlib.h>
#include <stdio.h>
#ifdef _MSC_VER
  #include <Windows.h>
#else
  #include <unistd.h>
  #include <pthread.h>
#endif
#include "lvgl/lvgl.h"
#include "lvgl/examples/lv_examples.h"
#include "lvgl/demos/lv_demos.h"
#include <SDL.h>

#include "hal/hal.h"

/* Include project-specific headers based on build configuration */
#ifdef PROJECT_HAIR_DRYER
  #include "hair_dryer.h"
#elif defined(PROJECT_SMART_SHAVER)
  #include "smart_shaver.h"
#elif defined(PROJECT_CHEETAH)
  #include "cheetah.h"
#elif defined(PROJECT_SLIDE_PLAYER)
  #include "slide_player.h"
#elif defined(PROJECT_BATTERY_MONITOR)
  #include "battery_monitor.h"
#elif defined(PROJECT_ACC_DATA)
  #include "acc_data.h"
#endif

#if defined(PROJECT_SMART_SHAVER) && defined(SMART_SHAVER_SCREEN_WIDTH) && defined(SMART_SHAVER_SCREEN_HEIGHT)
  #define WIDGET_SCREEN_WIDTH SMART_SHAVER_SCREEN_WIDTH
  #define WIDGET_SCREEN_HEIGHT SMART_SHAVER_SCREEN_HEIGHT
#elif defined(PROJECT_ACC_DATA) && defined(ACC_DATA_SCREEN_WIDTH) && defined(ACC_DATA_SCREEN_HEIGHT)
  #define WIDGET_SCREEN_WIDTH ACC_DATA_SCREEN_WIDTH
  #define WIDGET_SCREEN_HEIGHT ACC_DATA_SCREEN_HEIGHT
#endif

#ifndef WIDGET_SCREEN_WIDTH
  #define WIDGET_SCREEN_WIDTH 320
#endif

#ifndef WIDGET_SCREEN_HEIGHT
  #define WIDGET_SCREEN_HEIGHT 480
#endif

/*********************
 *      DEFINES
 *********************/

/**********************
 *      TYPEDEFS
 **********************/

/**********************
 *  STATIC PROTOTYPES
 **********************/

/**********************
 *  STATIC VARIABLES
 **********************/

/**********************
 *      MACROS
 **********************/

/**********************
 *   GLOBAL FUNCTIONS
 **********************/

#if LV_USE_OS != LV_OS_FREERTOS

int main(int argc, char **argv)
{
  (void)argc; /*Unused*/
  (void)argv; /*Unused*/

  /*Initialize LVGL*/
  lv_init();

  /*Initialize the HAL (display, input devices, tick) for LVGL*/
  /* Screen size is set based on the selected project */
  sdl_hal_init(WIDGET_SCREEN_WIDTH, WIDGET_SCREEN_HEIGHT);
#ifdef PROJECT_HAIR_DRYER
  /* Initialize Hair Dryer UI */
  hair_dryer_ui_init();
#elif defined(PROJECT_SMART_SHAVER)
  /* Initialize Smart Shaver UI */
  smart_shaver_ui_init();
#elif defined(PROJECT_CHEETAH)
  /* Initialize Cheetah UI */
  cheetah_ui_init();
#elif defined(PROJECT_SLIDE_PLAYER)
  /* Initialize Slide Player UI */
  slide_player_ui_init();
#elif defined(PROJECT_BATTERY_MONITOR)
  /* Initialize Battery Monitor UI */
  battery_monitor_ui_init();
#elif defined(PROJECT_ACC_DATA)
  /* Initialize Accelerometer Data UI */
  acc_data_ui_init();
#else
  /* Default: Run the demo widgets */
  lv_demo_widgets();
  //lv_example_label_1();
  //lv_demo_stress();
#endif

  while(1) {
    /* Periodically call the lv_task handler.
     * It could be done in a timer interrupt or an OS task too.*/
    uint32_t sleep_time_ms = lv_timer_handler();
    if(sleep_time_ms == LV_NO_TIMER_READY){
	sleep_time_ms =  LV_DEF_REFR_PERIOD;
    }
#ifdef _MSC_VER
    Sleep(sleep_time_ms);
#else
    usleep(sleep_time_ms * 1000);
#endif
  }

  return 0;
}


#endif

/**********************
 *   STATIC FUNCTIONS
 **********************/
