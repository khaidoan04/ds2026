from mpi4py import MPI
import os
import sys


def sender(comm: MPI.Comm, filepath: str) -> None:
    if not os.path.exists(filepath):
        if comm.rank == 0:
            print(f"[rank 0] File not found: {filepath}")
        return

    filename = os.path.basename(filepath)
    file_size = os.path.getsize(filepath)

    print(f"[rank 0] Sending file '{filename}' ({file_size / (1024 * 1024):.2f} MB) to rank 1")

    with open(filepath, "rb") as f:
        file_bytes = f.read()

    meta = {"name": filename, "size": file_size}
    comm.send(meta, dest=1, tag=0)

    comm.send(file_bytes, dest=1, tag=1)

    print(f"[rank 0] Transfer request sent.")


def receiver(comm: MPI.Comm, output_dir: str = ".") -> None:
    print("[rank 1] Waiting for file metadata from rank 0 ...")
    meta = comm.recv(source=0, tag=0)

    filename = meta["name"]
    file_size = meta["size"]

    print(
        f"[rank 1] Expecting file '{filename}' "
        f"({file_size / (1024 * 1024):.2f} MB) from rank 0"
    )

    file_bytes = comm.recv(source=0, tag=1)

    recv_name = f"MPI_RECV_{os.path.basename(filename)}"
    output_path = os.path.join(output_dir, recv_name)

    with open(output_path, "wb") as f:
        f.write(file_bytes)

    print(f"[rank 1] File stored as '{output_path}' "
          f"({len(file_bytes)} bytes received).")


def main() -> None:
    comm = MPI.COMM_WORLD
    rank = comm.rank
    size = comm.size

    if size != 2:
        if rank == 0:
            print(
                "This example expects exactly 2 MPI processes.\n"
                "Run it as:\n"
                "  mpiexec -n 2 python mpi_file_transfer.py <path_to_file>"
            )
        return

    if rank == 0:
        if len(sys.argv) < 2:
            print(
                f"Usage: mpiexec -n 2 python {sys.argv[0]} <path_to_file>\n"
                "Rank 0 is the sender, rank 1 is the receiver."
            )
            return

        filepath = sys.argv[1]
        sender(comm, filepath)
    elif rank == 1:
        receiver(comm)


if __name__ == "__main__":
    main()
