@api @skipOnOcV10
Feature: upload file
  As a user
  I want to be able to upload files
  So that I can store and share files between multiple client systems

  Background:
    Given user "Alice" has been created with default attributes and without skeleton files

  Scenario Outline: upload a file and check download content
    Given using <dav_version> DAV path
    When user "Alice" uploads file with content "uploaded content" to "<file_name>" using the TUS protocol on the WebDAV API
    Then the content of file "<file_name>" for user "Alice" should be "uploaded content"
    Examples:
      | dav_version | file_name         |
      | old         | /upload.txt       |
      | old         | /नेपाली.txt       |
      | old         | /strängé file.txt |
      | old         | /s,a,m,p,l,e.txt  |
      | old         | /C++ file.cpp     |
      | old         | /?fi=le&%#2 . txt |
      | old         | /# %ab ab?=ed     |
      | new         | /upload.txt       |
      | new         | /strängé file.txt |
      | new         | /नेपाली.txt       |
      | new         | /s,a,m,p,l,e.txt  |
      | new         | /C++ file.cpp     |
      | new         | /?fi=le&%#2 . txt |
      | new         | /# %ab ab?=ed     |

  Scenario Outline: upload a file into a folder and check download content
    Given using <dav_version> DAV path
    And user "Alice" has created folder "<folder_name>"
    When user "Alice" uploads file with content "uploaded content" to "<folder_name>/<file_name>" using the TUS protocol on the WebDAV API
    Then the content of file "<folder_name>/<file_name>" for user "Alice" should be "uploaded content"
    Examples:
      | dav_version | folder_name                      | file_name                     |
      | old         | /upload                          | abc.txt                       |
      | old         | /strängé folder                  | strängé file.txt              |
      | old         | /C++ folder                      | C++ file.cpp                  |
      | old         | /नेपाली                          | नेपाली                        |
      | old         | /folder #2.txt                   | file #2.txt                   |
      | old         | /folder ?2.txt                   | file ?2.txt                   |
      | old         | /?fi=le&%#2 . txt                | # %ab ab?=ed                  |
      | new         | /upload                          | abc.txt                       |
      | new         | /strängé folder (duplicate #2 &) | strängé file (duplicate #2 &) |
      | new         | /C++ folder                      | C++ file.cpp                  |
      | new         | /नेपाली                          | नेपाली                        |
      | new         | /folder #2.txt                   | file #2.txt                   |
      | new         | /folder ?2.txt                   | file ?2.txt                   |
      | new         | /?fi=le&%#2 . txt                | # %ab ab?=ed                  |


  Scenario Outline: Upload chunked file with TUS
    Given using <dav_version> DAV path
    When user "Alice" uploads file with content "uploaded content" in 3 chunks to "/myChunkedFile.txt" using the TUS protocol on the WebDAV API
    Then the content of file "/myChunkedFile.txt" for user "Alice" should be "uploaded content"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Upload 1 byte chunks with TUS
    Given using <dav_version> DAV path
    When user "Alice" uploads file with content "0123456789" in 10 chunks to "/myChunkedFile.txt" using the TUS protocol on the WebDAV API
    Then the content of file "/myChunkedFile.txt" for user "Alice" should be "0123456789"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Upload to overwriting a file
    Given using <dav_version> DAV path
    And user "Alice" has uploaded file with content "original content" to "textfile.txt"
    When user "Alice" uploads file with content "overwritten content" to "textfile.txt" using the TUS protocol on the WebDAV API
    Then the content of file "textfile.txt" for user "Alice" should be "overwritten content"
    Examples:
      | dav_version |
      | old         |
      | new         |

  @issue-ocis-1001
  Scenario Outline: upload a file with invalid-name and check download content
    Given using <dav_version> DAV path
    And user "Alice" has created a new TUS resource on the WebDAV API with these headers:
      | Upload-Length   | 10                  |
      | Tus-Resumable   | 1.0.0               |
      | Upload-Metadata | filename <metadata> |
    When user "Alice" sends a chunk to the last created TUS Location with offset "0" and data "123" using the WebDAV API
    Then the HTTP status code should be "204"
    And the content of file <file_name> for user "Alice" should be "123"
    Examples:
      | dav_version | file_name           | metadata                 |
      | old         | " "                 | IAo=                     |
      | old         | "filewithLF-and-CR" | ZmlsZXdpdGhMRi1hbmQtQ1IK |
      | old         | "folder/file"       | Zm9sZGVyL2ZpbGUK         |
      | old         | "my\\file"          | bXkMaWxl                 |
      | new         | " "                 | IAo=                     |
      | new         | "filewithLF-and-CR" | ZmlsZXdpdGhMRi1hbmQtQ1IK |
      | new         | "folder/file"       | Zm9sZGVyL2ZpbGUK         |
      | new         | "my\\file"          | bXkMaWxl                 |
