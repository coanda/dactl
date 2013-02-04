#ifndef __THREADS_H__
#define __THREADS_H__

#include "common.h"

BEGIN_C_DECLS

void threads_acq_func (GObject *data);
void threads_write_func (GObject *data);

END_C_DECLS

#endif /* !__THREADS_H__ */
