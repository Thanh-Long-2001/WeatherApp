package com.example.weatherapp_starter_project

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.app.PendingIntent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider


/**
 * Implementation of App Widget functionality.
 */
class CustomHomeView : HomeWidgetProvider() {
    
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
            widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val imageName = widgetData.getString("filename", null)
                setImageViewBitmap(R.id.widget_image, BitmapFactory.decodeFile(imageName))
                // End new code
            }

            // Thêm một PendingIntent để mở ứng dụng khi nhấn vào widget
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntentApp = PendingIntent.getActivity(context, 0, launchIntent, 0)

            // Thiết lập sự kiện khi nhấn vào widget
            views.setOnClickPendingIntent(R.id.widget_image, pendingIntentApp)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
