      MODULE GATE_MOD
      USE datetime_module
      USE COMMON_PARAM
      USE CONSTANTS
      USE TIME
      IMPLICIT NONE

      PUBLIC :: GATE_TYPE   ! STRUCT FOR GATE
      PUBLIC :: GATE_PTR    ! STRUCT FOR GATE POINTER


      TYPE GATE_TYPE
        !Gate name
        CHARACTER(100) :: NAME, DATAFILE
        !Type of gate
        INTEGER :: GATETYPE
        TYPE(DATETIME) :: TS, TE
        INTEGER :: NDATA, DT
        !Data
        CHARACTER(100) :: GATE_FILE
        REAL(8), POINTER, DIMENSION(:) :: GATE_DATA
        TYPE(DATETIME), POINTER, DIMENSION(:) :: TIME_ARR
        INTEGER :: CURRENT_INDEX
        REAL(8) :: CURRENT_DATA

        CONTAINS
        PROCEDURE,PASS(SEFT), PUBLIC :: READ_ALL_DATA
        PROCEDURE,PASS(SEFT), PUBLIC :: SET_CURRENT_DATA

      END TYPE GATE_TYPE

      TYPE GATE_PTR
        !POINTER
        TYPE(GATE_TYPE), POINTER :: GATE
      END TYPE GATE_PTR

      INTERFACE GATE_TYPE
        MODULE PROCEDURE :: GATE_TYPE_CONSTRUCTOR
      END INTERFACE GATE_TYPE

      CONTAINS

        !Constructor
        TYPE(GATE_TYPE) FUNCTION GATE_TYPE_CONSTRUCTOR(NAME, GTYPE, TSTART, TEND, FN, INTERVAL)
        IMPLICIT NONE
        CHARACTER(*), INTENT(IN) :: NAME, TSTART, TEND, FN
        INTEGER, INTENT(IN) :: INTERVAL, GTYPE
        TYPE(timedelta) :: DTIME
        INTEGER :: I


        GATE_TYPE_CONSTRUCTOR%NAME = TRIM(NAME)

        GATE_TYPE_CONSTRUCTOR%GATETYPE = GTYPE

        GATE_TYPE_CONSTRUCTOR%DATAFILE = TRIM(FN)

        IF(SIMULATION_MODE.EQ.VALIDATION_MODE) THEN

            GATE_TYPE_CONSTRUCTOR%TS = strptime(TRIM(TSTART), '%d-%m-%Y %H:%M')
            GATE_TYPE_CONSTRUCTOR%TE = strptime(TRIM(TEND), '%d-%m-%Y %H:%M')
            DTIME = GATE_TYPE_CONSTRUCTOR%TE - GATE_TYPE_CONSTRUCTOR%TS
            GATE_TYPE_CONSTRUCTOR%DT = INTERVAL
            GATE_TYPE_CONSTRUCTOR%NDATA = INT(DTIME%total_seconds()/INTERVAL) + 1
            ALLOCATE(GATE_TYPE_CONSTRUCTOR%TIME_ARR(0:GATE_TYPE_CONSTRUCTOR%NDATA - 1))
            GATE_TYPE_CONSTRUCTOR%CURRENT_INDEX = 0

            GATE_TYPE_CONSTRUCTOR%TIME_ARR(0) = GATE_TYPE_CONSTRUCTOR%TS
            DTIME = timedelta(0, 0, 0, GATE_TYPE_CONSTRUCTOR%DT, 0)

*            OPEN(30,FILE='TEST.DAT')
            DO I = 1, GATE_TYPE_CONSTRUCTOR%NDATA - 1

                GATE_TYPE_CONSTRUCTOR%TIME_ARR(I) = GATE_TYPE_CONSTRUCTOR%TIME_ARR(I - 1) + DTIME
*                WRITE(30,*) GATE_TYPE_CONSTRUCTOR%TIME_ARR(I)%strftime('%d-%m-%Y %H:%M')

            ENDDO
*            PRINT*,'AAAAAAAAAAAAA'
*            CLOSE(30)
*            STOP

        ELSE

            GATE_TYPE_CONSTRUCTOR%TS = START_TIME
            GATE_TYPE_CONSTRUCTOR%TE = END_TIME
            GATE_TYPE_CONSTRUCTOR%DT = INT(DT)
            GATE_TYPE_CONSTRUCTOR%NDATA = 0

        ENDIF

        END FUNCTION GATE_TYPE_CONSTRUCTOR


        !READ ALL DATA FROM RECORD FILE
        SUBROUTINE READ_ALL_DATA(SEFT)

            CLASS(GATE_TYPE), INTENT(INOUT) :: SEFT
            INTEGER :: FU, J, IERR, IDX, CNT
            CHARACTER(100) :: LINE


            FU = 10

            OPEN(UNIT=FU, FILE=TRIM(SEFT%DATAFILE), STATUS='OLD')

            ALLOCATE(SEFT%GATE_DATA(0:SEFT%NDATA - 1), STAT=IERR)
            CALL ChkMemErr('GATE_DATA', IERR)

            CNT = 0
            DO J = 0, SEFT%NDATA - 1
                LINE = ""
                READ(FU,'(A)', END = 99) LINE
                !IDX = INDEX(LINE,',') + 1
                IDX = INDEX(LINE,TAB) + 1
                READ(LINE(IDX:),*) SEFT%GATE_DATA(J)
                CNT = CNT + 1
            ENDDO
99          CONTINUE
            IF(CNT.NE.SEFT%NDATA) CALL WRITE_ERRORS("NOT ENOUGH DATA IN GATE "//TRIM(SEFT%NAME))
            CLOSE(FU)

        END SUBROUTINE READ_ALL_DATA


        !READ DATA AT CURRENT TIME
        INTEGER FUNCTION SET_CURRENT_DATA(SEFT)

            CLASS(GATE_TYPE), INTENT(INOUT) :: SEFT
            CHARACTER(17) :: CTIME
            CHARACTER(100) :: LINE
            TYPE(datetime) :: CRRTIME
            REAL(8) :: CRRVAL
            INTEGER :: FU, IDX

            IF(SIMULATION_MODE.EQ.VALIDATION_MODE) THEN

                DO WHILE(.TRUE.)
                    IF(CURRENT_TIME .EQ.SEFT%TIME_ARR(SEFT%CURRENT_INDEX)) THEN
                        SEFT%CURRENT_DATA = SEFT%GATE_DATA(SEFT%CURRENT_INDEX)
                        SEFT%CURRENT_INDEX = SEFT%CURRENT_INDEX + 1
                        SET_CURRENT_DATA = 0
                        RETURN
                    ENDIF
                    SEFT%CURRENT_INDEX = SEFT%CURRENT_INDEX + 1
                    IF(SEFT%CURRENT_INDEX.GT.SEFT%NDATA) THEN
                        SET_CURRENT_DATA = 1
                        RETURN
                    ENDIF
                ENDDO

            ELSE

                FU = 10
                CRRVAL = 0.0D0
                CRRTIME = SEFT%TS
                SEFT%CURRENT_DATA = -1000.0D0
                OPEN(UNIT=FU, FILE=TRIM(SEFT%DATAFILE), STATUS='OLD')

                DO WHILE(.TRUE.)

                    LINE = ""
                    READ(FU,'(A)', END = 99) LINE
                    !IDX = INDEX(LINE,',')
                    IDX = INDEX(LINE,TAB)
                    READ(LINE(1:IDX - 1), '(A17)') CTIME
                    READ(LINE(IDX+1:),*) CRRVAL
                    CRRTIME = strptime(ADJUSTL(TRIM(CTIME)), '%d-%m-%Y %H:%M')

                    IF(CRRTIME.EQ.CURRENT_TIME) THEN
                        SEFT%CURRENT_DATA = CRRVAL
                        SET_CURRENT_DATA = 0
                        GOTO 105
                    ENDIF

                ENDDO

99              SET_CURRENT_DATA = 1
105             CLOSE(FU)
            ENDIF

        END FUNCTION SET_CURRENT_DATA

      END MODULE GATE_MOD


*      MODULE GATE_PTR_LIST_MOD
*      USE GATE_MOD
*
*#define LIST_DATA GATE_PTR
*#include "linkedlist.f90"
*#undef LIST_DATA
*
*      END MODULE GATE_PTR_LIST_MOD

