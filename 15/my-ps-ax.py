import os

def list_processes():
    processes = []
    for pid in os.listdir("/proc"):
        if pid.isdigit():
            try:
                with open(f"/proc/{pid}/stat", "r") as f:
                    data = f.read().split()
                    pid = data[0]
                    comm = data[1].strip("()")
                    state = data[2]
                    ppid = data[3]
                    pgrp = data[4]
                    session = data[5]
                    tty_nr = data[6]
                    tpgid = data[7]

                processes.append((pid, comm, state, ppid, pgrp, session, tty_nr, tpgid))
            except FileNotFoundError:
                continue  # Процесс мог завершиться
            except Exception as e:
                print(f"Ошибка при обработке PID {pid}: {e}")

    print("PID  COMMAND        STATE PPID PGRP SESSION TTY_NR TPGID")
    for p in processes:
        print(" ".join(p))

if __name__ == "__main__":
    list_processes()
