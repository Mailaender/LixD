module net.enetglob;

/* Globals for NetServer and NetClient to bookkeep enet initialization.
 * User code (outside of package net) should not call these funcs, instead, it
 * should instantiate NetClient or NetServer, and let those call these funcs.
 */

import std.string;
import derelict.enet.enet;

private bool _enetDllLoaded = false;
private int _enetInits = 0;

package:

void initializeEnet()
{
    if (! _enetDllLoaded) {
        DerelictENet.load(); // may throw, caught in module menu.lobby.connect
        _enetDllLoaded = true;
    }
    if (_enetInits == 0) {
        if (enet_initialize() != 0)
            assert (false, "error initializing enet");
    }
    ++_enetInits;
    assert (_enetInits > 0);
}

void deinitializeEnet()
{
    _enetInits = (_enetInits > 0) ? (_enetInits - 1) : 0;
    if (_enetInits == 0)
        enet_deinitialize();
}

string enetLinkedVersion()
{
    assert (_enetDllLoaded);
    immutable ver = enet_linked_version();
    return format("%d.%d.%d", ENET_VERSION_GET_MAJOR(ver),
        ENET_VERSION_GET_MINOR(ver), ENET_VERSION_GET_PATCH(ver));
}

ENetPacket* createPacket(T)(T wantLen) nothrow
    if (is (T == int) || is (T == size_t))
{
    return enet_packet_create(null, wantLen & 0x7FFF_FFFF,
        ENET_PACKET_FLAG_RELIABLE);
}

/*
 * enetSendTo:
 * Tries once to send the packet. No retry on failure.
 * Two versions. The template version doesn't modify the source struct.
 * You can send it somewhere else after this, or let it go out of scope.
 */
void enetSendTo(Struct, Args...)(
    in Struct st,
    ENetPeer* dest,
    Args args,
)   if (!is (Struct == ENetPacket*))
{
    ENetPacket* packet = st.createPacket(args);
    immutable err = enet_peer_send(dest, 0, packet);
    // enet_peer_send only deallocates on success (err == 0).
    if (err < 0) {
        enet_packet_destroy(packet);
    }
    // Here, packet has been deallocated exactly once.
}
