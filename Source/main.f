      PROGRAM HYDRAULIC_MODELLING
      USE COMMON_PARAM
      USE CALC_PARAM
      USE CONSTANTS
      USE TIME
      IMPLICIT NONE

C Open log file
      OPEN(UNIT=ULOG, FILE=TRIM(FLOG),STATUS='REPLACE')

C Introduction
      CALL GETCWD(ROOT_DIR)
      CALL WRITE_LOG('===================================')
      CALL WRITE_LOG('=                                 =')
      CALL WRITE_LOG('=   WELCOME TO HYDROLOGIC MODEL   =')
      CALL WRITE_LOG('=                                 =')
      CALL WRITE_LOG('===================================')
      CALL WRITE_LOG('')
      CALL WRITE_LOG('WORKING DIRECTORY: '//TRIM(ROOT_DIR))

C Read input parameters
      CALL READING_INPUT

C Find the connection of basing
      CALL BASIN_CONNECTION

C Allocate necessary variables
      CALL ALLOCATING_VARIABLES

C Initial variables
      CALL INITIALING_VARIABLES

C Starting calculate
      CALL WRITE_LOG('===================================')
      CALL WRITE_LOG('=      STARTING CALCULATION       =')
      IF(SIMULATION_MODE.EQ.REAL_TIME_MODE)CALL WRITE_LOG('=      REAL TIME SIMULATION       =')
      IF(SIMULATION_MODE.EQ.VALIDATION_MODE)CALL WRITE_LOG('=         VALIDATION MODE         =')
      CALL WRITE_LOG('===================================')


      IF(SIMULATION_MODE.EQ.REAL_TIME_MODE) CALL RUN_REAL_TIME_MODE
      IF(SIMULATION_MODE.EQ.VALIDATION_MODE) CALL RUN_VALIDATION_MODE



      CALL WRITE_LOG('===================================')
      CALL WRITE_LOG('=                                 =')
      CALL WRITE_LOG('=        END OF CALCULATION       =')
      CALL WRITE_LOG('=                                 =')
      CALL WRITE_LOG('===================================')
      CALL WRITE_LOG('')
      CLOSE(ULOG)

      WRITE(*,*) 'PRESS ANY KEY TO STOP!!!'
      READ(*,*)
      END PROGRAM HYDRAULIC_MODELLING

