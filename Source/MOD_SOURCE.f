      MODULE SOURCE_MOD
      USE datetime_module
      USE GATE_MOD
      IMPLICIT NONE

      PUBLIC :: SOURCE_TYPE
      PUBLIC :: SOURCE_PTR

      TYPE SOURCE_TYPE

        CHARACTER(100) :: NAME
        !Source type
        INTEGER :: SRC_TYPE
        !Data
        REAL(8) :: CONST_DATA
        TYPE(GATE_TYPE), POINTER :: SRC_DATA
        !Downstream
        CHARACTER(100) :: DOWNSTREAM

        CONTAINS

        PROCEDURE,PASS(SEFT), PUBLIC :: SET_DATA_PARAM

      END TYPE SOURCE_TYPE

      TYPE SOURCE_PTR
        !POINTER
        TYPE(SOURCE_TYPE), POINTER :: SOURCE
      END TYPE SOURCE_PTR

      INTERFACE SOURCE_TYPE
        MODULE PROCEDURE :: SOURCE_TYPE_CONSTRUCTOR
      END INTERFACE SOURCE_TYPE

      CONTAINS

        !Constructor
        PURE ELEMENTAL TYPE(SOURCE_TYPE) FUNCTION SOURCE_TYPE_CONSTRUCTOR(NAME, DOWNSTREAM)
        IMPLICIT NONE
        CHARACTER(*), INTENT(IN) :: NAME, DOWNSTREAM


        SOURCE_TYPE_CONSTRUCTOR%NAME = TRIM(NAME)
        SOURCE_TYPE_CONSTRUCTOR%DOWNSTREAM = TRIM(DOWNSTREAM)

        END FUNCTION SOURCE_TYPE_CONSTRUCTOR

        !Set parameter for Source data
        SUBROUTINE SET_DATA_PARAM(SEFT, STYPE, CONST_DATA, SRC_GATE, GATEARR, NGARR)

            CLASS(SOURCE_TYPE), INTENT(INOUT) :: SEFT
            TYPE(GATE_TYPE), POINTER, DIMENSION(:):: GATEARR
            CHARACTER(*), INTENT(IN) :: SRC_GATE
            INTEGER, INTENT(IN) :: STYPE, NGARR
            REAL(8), INTENT(IN) :: CONST_DATA
            INTEGER :: J

            SEFT%SRC_TYPE = STYPE
            SEFT%SRC_DATA => NULL()
            IF(STYPE.EQ.CONSTANT_DATA) THEN

                SEFT%CONST_DATA = CONST_DATA

            ELSE

                DO J = 1, NGARR

                    IF(TRIM(GATEARR(J)%NAME).EQ.TRIM(SRC_GATE)) SEFT%SRC_DATA => GATEARR(J)

                ENDDO

                IF(.NOT.ASSOCIATED(SEFT%SRC_DATA)) CALL WRITE_ERRORS('Undefined source gate named '//TRIM(SRC_GATE))

            ENDIF

        END SUBROUTINE SET_DATA_PARAM


      END MODULE SOURCE_MOD

      MODULE SOURCE_PTR_LIST_MOD
      USE SOURCE_MOD

#define LIST_DATA SOURCE_PTR
#include "linkedlist.f90"
#undef LIST_DATA

      END MODULE SOURCE_PTR_LIST_MOD