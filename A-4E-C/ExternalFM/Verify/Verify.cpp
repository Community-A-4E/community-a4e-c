#include <Common/Hashes.h>
#include <Verify.h>

extern "C"
{
#include <Common/md5.h>
}
#include <fstream>
#include <string>
namespace Scooter
{
    bool Verify( const char* config )
    {
        std::string content = "";

        std::string line;
        for ( const char* file_path : files )
        {
            line = config;
            line += "/";
            line += file_path;
            std::ifstream file(line); // Use Line for Both filepath and line
            while ( std::getline( file, line ) )
            {
                content += line;
            }
        }

        MD5_CTX ctx;
        MD5_Init(&ctx);
        MD5_Update(&ctx, content.data(), content.size());
        
        unsigned char current_hash[16];
        MD5_Final(current_hash, &ctx);

        static_assert( std::size(current_hash) == std::size(hash) );

        for ( int i = 0; i < 16; i++ )
        {
            if ( current_hash[i] != hash[i] )
                return false;
        }

        return true;
    }
}