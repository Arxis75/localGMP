# Crée des variables avec les fichiers à compiler
#set(SRCS
#    *.cpp
#    )

#set(HEADERS
#    *.h
#    )
    
# Notre exécutable
#add_executable(main ${HEADERS} ${SRCS})
add_executable(main main.cpp)

target_link_libraries(main PUBLIC ethash::ethash givaro::givaro OpenSSL::Crypto)