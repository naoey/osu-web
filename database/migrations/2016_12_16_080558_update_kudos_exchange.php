<?php

use Illuminate\Database\Migrations\Migration;

class UpdateKudosExchange extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement('
            ALTER TABLE osu_kudos_exchange
            MODIFY giver_id MEDIUMINT UNSIGNED NULL,
            MODIFY post_id MEDIUMINT UNSIGNED NULL,
            ADD kudosuable_type VARCHAR(255) NULL,
            ADD kudosuable_id BIGINT UNSIGNED NULL,
            ADD details TEXT NULL
        ');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement('
            ALTER TABLE osu_kudos_exchange
            MODIFY giver_id MEDIUMINT UNSIGNED NOT NULL,
            MODIFY post_id MEDIUMINT UNSIGNED NOT NULL,
            DROP kudosuable_type,
            DROP kudosuable_id,
            DROP details
        ');
    }
}
