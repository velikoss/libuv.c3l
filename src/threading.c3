<*
 Threads and synchronisation primitives.

 Only `Async.send` may be called on a loop from another thread. Everything here
 is thread safe by construction.
*>
module libuv;

// Mutex

<* @param [&out] self *>
fn void? Mutex.init(&self) => check(api::uv_mutex_init(self));

<*
 Initialises a mutex the same thread may lock more than once.

 @param [&out] self
*>
fn void? Mutex.init_recursive(&self) => check(api::uv_mutex_init_recursive(self));

<* @param [&inout] self *>
fn void Mutex.destroy(&self) => api::uv_mutex_destroy(self);

<* @param [&inout] self *>
fn void Mutex.lock(&self) => api::uv_mutex_lock(self);

<*
 Takes the mutex if it is free. Fails with `EBUSY` when it is not.

 @param [&inout] self
*>
fn void? Mutex.trylock(&self) => check(api::uv_mutex_trylock(self));

<* @param [&inout] self *>
fn void Mutex.unlock(&self) => api::uv_mutex_unlock(self);

// Read-write lock

<* @param [&out] self *>
fn void? RwLock.init(&self) => check(api::uv_rwlock_init(self));

<* @param [&inout] self *>
fn void RwLock.destroy(&self) => api::uv_rwlock_destroy(self);

<* @param [&inout] self *>
fn void RwLock.rdlock(&self) => api::uv_rwlock_rdlock(self);

<*
 Takes the read lock if it is free. Fails with `EBUSY` when it is not.

 @param [&inout] self
*>
fn void? RwLock.tryrdlock(&self) => check(api::uv_rwlock_tryrdlock(self));

<* @param [&inout] self *>
fn void RwLock.rdunlock(&self) => api::uv_rwlock_rdunlock(self);

<* @param [&inout] self *>
fn void RwLock.wrlock(&self) => api::uv_rwlock_wrlock(self);

<*
 Takes the write lock if it is free. Fails with `EBUSY` when it is not.

 @param [&inout] self
*>
fn void? RwLock.trywrlock(&self) => check(api::uv_rwlock_trywrlock(self));

<* @param [&inout] self *>
fn void RwLock.wrunlock(&self) => api::uv_rwlock_wrunlock(self);

// Semaphore

<*
 @param value : "the initial count"
 @param [&out] self
*>
fn void? Sem.init(&self, CUInt value) => check(api::uv_sem_init(self, value));

<* @param [&inout] self *>
fn void Sem.destroy(&self) => api::uv_sem_destroy(self);

<* Raises the count by one, waking a waiter. @param [&inout] self *>
fn void Sem.post(&self) => api::uv_sem_post(self);

<* Blocks until the count is positive, then lowers it. @param [&inout] self *>
fn void Sem.wait(&self) => api::uv_sem_wait(self);

<*
 Lowers the count if it is positive. Fails with `EAGAIN` when it is not.

 @param [&inout] self
*>
fn void? Sem.trywait(&self) => check(api::uv_sem_trywait(self));

// Condition variable

<* @param [&out] self *>
fn void? Cond.init(&self) => check(api::uv_cond_init(self));

<* @param [&inout] self *>
fn void Cond.destroy(&self) => api::uv_cond_destroy(self);

<* Wakes one waiter. @param [&inout] self *>
fn void Cond.signal(&self) => api::uv_cond_signal(self);

<* Wakes every waiter. @param [&inout] self *>
fn void Cond.broadcast(&self) => api::uv_cond_broadcast(self);

<*
 Releases `mutex`, waits, and retakes it.

 Spurious wakeups happen, so always re-test the predicate in a loop.

 @param [&inout] self
 @param [&inout] mutex
*>
fn void Cond.wait(&self, Mutex* mutex) => api::uv_cond_wait(self, mutex);

<*
 `Cond.wait` with a deadline. Fails with `ETIMEDOUT` when it expires.

 @param timeout : "nanoseconds to wait"
 @param [&inout] self
 @param [&inout] mutex
*>
fn void? Cond.timedwait(&self, Mutex* mutex, ulong timeout) => check(api::uv_cond_timedwait(self, mutex, timeout));

// Barrier

<*
 @param count : "how many threads must arrive before any may pass"
 @require count > 0
 @param [&out] self
*>
fn void? Barrier.init(&self, CUInt count) => check(api::uv_barrier_init(self, count));

<*
 Releases the barrier.

 Call it exactly once, from the thread whose `Barrier.wait` returned true.

 @param [&inout] self
*>
fn void Barrier.destroy(&self) => api::uv_barrier_destroy(self);

<*
 Waits for the other threads to arrive.

 @return "true in exactly one of the threads, which is the one that should call `Barrier.destroy`"
 @param [&inout] self
*>
fn bool? Barrier.wait(&self) => check_value(api::uv_barrier_wait(self))! > 0;

// Once and thread local storage

<*
 Runs `callback` the first time this guard is used, and never again.

 The guard must be zero initialised and must live as long as the program.

 @require callback != null
 @param [&inout] guard
*>
fn void once(Once* guard, OnceCallback callback) => api::uv_once(guard, callback);

<* @param [&out] self *>
fn void? Key.create(&self) => check(api::uv_key_create(self));

<* @param [&inout] self *>
fn void Key.delete(&self) => api::uv_key_delete(self);

<* The value this thread stored under the key, or null. *>
fn void* Key.get(&self) => api::uv_key_get(self);

<* Stores a value under the key for this thread only. *>
fn void Key.set(&self, void* value) => api::uv_key_set(self, value);

// Threads

<*
 Starts a thread running `entry`.

 @require entry != null
 @param [out] tid
*>
fn void? thread_create(Thread* tid, ThreadCallback entry, void* arg = null)
	=> check(api::uv_thread_create(tid, entry, arg));

<*
 `thread_create` with a chosen stack size.

 @require entry != null
 @param [out] tid
*>
fn void? thread_create_ex(Thread* tid, ThreadOptions* params, ThreadCallback entry, void* arg = null)
	=> check(api::uv_thread_create_ex(tid, params, entry, arg));

<*
 Detaches the thread so that its resources are reclaimed when it ends.

 A detached thread must not be joined.
*>
fn void? thread_detach(Thread* tid) => check(api::uv_thread_detach(tid));

<* Waits for the thread to finish. *>
fn void? thread_join(Thread* tid) => check(api::uv_thread_join(tid));

<* The calling thread. *>
fn Thread thread_self() => api::uv_thread_self();

<* True when the two handles refer to the same thread. *>
fn bool thread_equal(Thread* t1, Thread* t2) => api::uv_thread_equal(t1, t2) != 0;

<*
 Names the calling thread. Truncated to what the platform allows, which is 15
 characters plus a NUL on Linux.
*>
fn void? thread_setname(String name) => @pool()
{
	return check(api::uv_thread_setname(name.zstr_tcopy()));
}

<*
 Copies the thread's name into `name`.

 @param [out] name
 @require name.len > 0
*>
fn void? thread_getname(Thread* tid, char[] name) => check(api::uv_thread_getname(tid, name.ptr, name.len));

<*
 Reads the thread's scheduling priority.

 @param [out] priority : "one of the `THREAD_PRIORITY_*` values"
*>
fn void? thread_getpriority(Thread tid, CInt* priority) => check(api::uv_thread_getpriority(tid, priority));

<*
 Sets the thread's scheduling priority.

 @param priority : "one of the `THREAD_PRIORITY_*` values"
*>
fn void? thread_setpriority(Thread tid, CInt priority) => check(api::uv_thread_setpriority(tid, priority));

<*
 Pins the thread to a set of CPUs. Not supported on macOS or Windows.

 @param cpumask : "one byte per CPU, non-zero to allow; size it with `libuv::cpumask_size`"
 @param oldmask : "receives the previous mask, or null"
 @require cpumask.len > 0
*>
fn void? thread_setaffinity(Thread* tid, char[] cpumask, char* oldmask = null)
	=> check(api::uv_thread_setaffinity(tid, cpumask.ptr, oldmask, cpumask.len));

<*
 Reads the thread's CPU affinity mask.

 @param [out] cpumask : "one byte per CPU; size it with `libuv::cpumask_size`"
 @require cpumask.len > 0
*>
fn void? thread_getaffinity(Thread* tid, char[] cpumask)
	=> check(api::uv_thread_getaffinity(tid, cpumask.ptr, cpumask.len));

<*
 The CPU the calling thread is running on.

 @return "the CPU number"
*>
fn CInt? thread_getcpu() => check_value(api::uv_thread_getcpu());

<*
 Bytes an affinity mask needs.

 @return "the mask size, or a fault when the platform has no affinity support"
*>
fn CInt? cpumask_size() => check_value(api::uv_cpumask_size());
