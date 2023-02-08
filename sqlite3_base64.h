#include <sqlite3ext.h>

#ifdef __cplusplus
extern "C" {
#endif

int sqlite3_basesixtyfour_init(
  sqlite3 * db,
  char **pzErrMsg,
  const sqlite3_api_routines *pApi
);

#ifdef __cplusplus
}
#endif
